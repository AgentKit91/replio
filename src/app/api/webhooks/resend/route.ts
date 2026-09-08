import {NextRequest,NextResponse} from "next/server";
import {Resend} from "resend";
import sanitizeHtml from "sanitize-html";
import {z} from "zod";
import {commercialMessageFingerprint,extractForwardedSender,managedReplyTarget} from "@/features/email/normalization";
import {requireManagedEmailServerEnv} from "@/lib/env.server";
import {createAdminClient} from "@/lib/supabase/admin";

const receivedEvent=z.object({type:z.literal("email.received"),created_at:z.iso.datetime(),data:z.object({email_id:z.string().uuid(),message_id:z.string().min(1),from:z.string(),to:z.array(z.email()),cc:z.array(z.email()).optional(),subject:z.string()})});
export async function POST(request:NextRequest){
  let env;try{env=requireManagedEmailServerEnv();}catch{return NextResponse.json({error:"Managed email inactive"},{status:503});}
  const payload=await request.text();const id=request.headers.get("svix-id"),timestamp=request.headers.get("svix-timestamp"),signature=request.headers.get("svix-signature");if(!id||!timestamp||!signature)return NextResponse.json({error:"Invalid signature"},{status:400});
  const resend=new Resend(env.RESEND_API_KEY);let verified:unknown;try{verified=resend.webhooks.verify({payload,headers:{id,timestamp,signature},webhookSecret:env.RESEND_WEBHOOK_SECRET});}catch{return NextResponse.json({error:"Invalid signature"},{status:400});}
  const event=receivedEvent.safeParse(verified);if(!event.success)return new NextResponse(null,{status:204});
  const received=await resend.emails.receiving.get(event.data.data.email_id,{html_format:"cid"});if(received.error||!received.data)return NextResponse.json({error:"Message retrieval failed"},{status:503});
  const email=received.data;if((email.text?.length??0)>200000||(email.html?.length??0)>500000||email.attachments.some(item=>item.size>15_000_000))return new NextResponse(null,{status:204});
  const sanitized=email.html?sanitizeHtml(email.html,{allowedTags:["p","br","div","span","strong","b","em","i","u","blockquote","ul","ol","li","a"],allowedAttributes:{a:["href","title"]},allowedSchemes:["http","https","mailto"],disallowedTagsMode:"discard"}):null;
  const text=(email.text??(sanitized?sanitizeHtml(sanitized,{allowedTags:[],allowedAttributes:{}}):"")).trim();const forwarded=extractForwardedSender(text);const safeReplyTarget=managedReplyTarget({from:email.from,forwarded,replyTo:email.reply_to??[]});
  const fingerprint=commercialMessageFingerprint({from:email.from,to:email.to,subject:email.subject,body:text,receivedAt:email.created_at});
  const admin=createAdminClient();const headers=email.headers??{};const threadId=headers["in-reply-to"]??headers["references"]?.split(/\s+/)[0]??email.message_id;const {data:messageId,error}=await admin.rpc("ingest_managed_email",{p_provider_event_id:id,p_provider_email_id:email.id,p_message_id:email.message_id,p_from:email.from,p_to:email.to,p_cc:email.cc??[],p_reply_to:safeReplyTarget?[safeReplyTarget]:[],p_subject:email.subject,p_body_text:text,p_body_html:sanitized,p_received_at:email.created_at,p_headers:{...headers,"thread-id":threadId},p_original_sender:safeReplyTarget,p_forwarded_by:forwarded.isForwarded?email.from:null,p_fingerprint:fingerprint});
  if(error)return NextResponse.json({error:"Message persistence failed"},{status:503});
  if(messageId&&email.attachments.length){const {data:stored}=await admin.from("gmail_messages").select("workspace_id").eq("id",messageId).single();if(stored)await admin.from("gmail_attachment_references").upsert(email.attachments.map(item=>({workspace_id:stored.workspace_id,gmail_message_id:messageId,provider_attachment_id:item.id,filename:item.filename??"attachment",mime_type:item.content_type,size_bytes:item.size,transport_provider:"resend",safety_status:"metadata_only"})),{onConflict:"gmail_message_id,provider_attachment_id"});}
  return new NextResponse(null,{status:204});
}

