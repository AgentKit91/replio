"use client";

import { useEffect,useRef,useState } from "react";
import { saveReplyDraft } from "@/app/deals/actions";

type Draft={dealId:string;subject:string;body:string;version:number};
export function ReplyComposer({draft}:{draft:Draft}){
  const [subject,setSubject]=useState(draft.subject); const [body,setBody]=useState(draft.body); const [status,setStatus]=useState<"saved"|"saving"|"error">("saved");
  const versionRef=useRef(draft.version); const pendingRef=useRef<{subject:string;body:string}|null>(null); const savingRef=useRef(false); const hydratedRef=useRef(false);
  useEffect(()=>{if(!hydratedRef.current){hydratedRef.current=true;return;} pendingRef.current={subject,body}; const timer=window.setTimeout(async()=>{
    if(savingRef.current)return; savingRef.current=true;
    while(pendingRef.current){const next=pendingRef.current;pendingRef.current=null;setStatus("saving");const result=await saveReplyDraft({dealId:draft.dealId,...next,expectedVersion:versionRef.current});if(!result.ok){setStatus("error");break;}versionRef.current=result.version;setStatus("saved");}
    savingRef.current=false;
  },1000);return()=>window.clearTimeout(timer);},[subject,body,draft.dealId]);
  return <section className="reply-composer" aria-label="Suggested reply editor"><div className="reply-composer-heading"><div><p className="eyebrow">Replio prepared a reply</p><h3>Edit before sending</h3></div><span className={`save-state save-${status}`}>{status==="saving"?"Saving…":status==="error"?"Save failed":"Saved"}</span></div>
    <label>Subject<input value={subject} maxLength={998} onChange={(event)=>setSubject(event.target.value)}/></label>
    <label>Message<textarea value={body} maxLength={100000} onChange={(event)=>setBody(event.target.value)}/></label>
    <div className="composer-actions"><p className="muted">Your edits are versioned automatically. Sending is not active yet.</p><button className="button button-primary" disabled>Send</button></div>
  </section>;
}
