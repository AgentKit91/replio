"use client";

import { useCallback,useEffect,useRef,useState } from "react";
import { useRouter } from "next/navigation";
import { queueReplySend,saveReplyDraft } from "@/app/deals/actions";

type Draft={dealId:string;subject:string;body:string;version:number};
export function ReplyComposer({draft}:{draft:Draft}){
  const [subject]=useState(draft.subject); const [body,setBody]=useState(draft.body); const [status,setStatus]=useState<"saved"|"saving"|"error">("saved");
  const versionRef=useRef(draft.version); const pendingRef=useRef<{subject:string;body:string}|null>(null); const savingPromiseRef=useRef<Promise<boolean>|null>(null); const hydratedRef=useRef(false);
  const router=useRouter();
  const flush=useCallback(async()=>{
    if(savingPromiseRef.current)return savingPromiseRef.current;
    const work=(async()=>{while(pendingRef.current){const next=pendingRef.current;pendingRef.current=null;setStatus("saving");const result=await saveReplyDraft({dealId:draft.dealId,...next,expectedVersion:versionRef.current});if(!result.ok){setStatus("error");return false;}versionRef.current=result.version;setStatus("saved");}return true;})();
    savingPromiseRef.current=work;const ok=await work;savingPromiseRef.current=null;return ok;
  },[draft.dealId]);
  useEffect(()=>{if(!hydratedRef.current){hydratedRef.current=true;return;} pendingRef.current={subject,body};const timer=window.setTimeout(()=>void flush(),1000);return()=>window.clearTimeout(timer);},[subject,body,flush]);
  async function send(){if(!window.confirm("Send this reply now from your connected Gmail account?"))return;pendingRef.current={subject,body};if(!await flush())return;const result=await queueReplySend({dealId:draft.dealId,expectedVersion:versionRef.current});if(!result.ok){setStatus("error");return;}router.refresh();}
  return <section className="reply-composer" aria-label="Suggested reply editor"><div className="reply-composer-heading"><div><p className="eyebrow">Replio prepared a reply</p><h3>Edit before sending</h3></div><span className={`save-state save-${status}`}>{status==="saving"?"Saving…":status==="error"?"Save failed":"Saved"}</span></div>
    <label>Subject<input value={subject} maxLength={998} readOnly aria-describedby="thread-subject-note"/></label><small id="thread-subject-note" className="muted">Kept unchanged so Gmail preserves the conversation thread.</small>
    <label>Message<textarea value={body} maxLength={100000} onChange={(event)=>setBody(event.target.value)}/></label>
    <div className="composer-actions"><p className="muted">Your edits are versioned automatically.</p><button type="button" className="button button-primary" onClick={()=>void send()} disabled={status==="saving"}>Send reply</button></div>
  </section>;
}
