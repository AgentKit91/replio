import {timingSafeEqual} from "node:crypto";
import {NextRequest,NextResponse} from "next/server";
import {Resend} from "resend";
import {z} from "zod";
import {requireManagedEmailServerEnv,serverEnv} from "@/lib/env.server";
import {createAdminClient} from "@/lib/supabase/admin";

const attachmentSchema=z.object({bucket:z.literal("invoice-pdfs"),path:z.string().min(1).max(500),filename:z.string().min(1).max(200),mimeType:z.literal("application/pdf")});
const jobSchema=z.object({queueMessageId:z.number(),jobId:z.uuid(),draftId:z.uuid(),fromAddress:z.email(),toAddress:z.email(),subject:z.string(),body:z.string(),attachmentRefs:z.array(attachmentSchema).max(1).default([]),idempotencyKey:z.string().min(1).max(256),inReplyTo:z.string().nullish(),references:z.string()});
function authorized(request:NextRequest){const expected=serverEnv.INTERNAL_JOB_SECRET;const supplied=request.headers.get("authorization")?.replace(/^Bearer\s+/i,"");if(!expected||!supplied)return false;const a=Buffer.from(expected),b=Buffer.from(supplied);return a.length===b.length&&timingSafeEqual(a,b);}
export async function POST(request:NextRequest){
  if(!authorized(request))return NextResponse.json({error:"Unauthorized"},{status:401});let env;try{env=requireManagedEmailServerEnv();}catch{return NextResponse.json({error:"Managed email inactive"},{status:503});}
  const admin=createAdminClient();const {data,error}=await admin.rpc("claim_managed_email_send");if(error)return NextResponse.json({error:"Queue claim failed"},{status:500});if(!data)return new NextResponse(null,{status:204});
  const job=jobSchema.parse(data);const attachments=[];for(const ref of job.attachmentRefs){const {data:file,error:fileError}=await admin.storage.from(ref.bucket).download(ref.path);if(fileError||!file){await admin.rpc("finish_managed_email_send",{p_queue_message_id:job.queueMessageId,p_job_id:job.jobId,p_provider_message_id:null,p_error_class:"attachment_unavailable"});return NextResponse.json({error:"Delivery will retry"},{status:503});}attachments.push({filename:ref.filename,content:Buffer.from(await file.arrayBuffer())});}
  try{const resend=new Resend(env.RESEND_API_KEY);const headers:Record<string,string>={};if(job.inReplyTo){headers["In-Reply-To"]=job.inReplyTo;headers.References=[job.references,job.inReplyTo].filter(Boolean).join(" ");}const sent=await resend.emails.send({from:`${env.MANAGED_EMAIL_FROM_NAME} <${job.fromAddress}>`,to:[job.toAddress],subject:job.subject,text:job.body,headers,attachments},{idempotencyKey:job.idempotencyKey});if(sent.error||!sent.data)throw new Error("ResendSendFailed");
    await admin.rpc("finish_managed_email_send",{p_queue_message_id:job.queueMessageId,p_job_id:job.jobId,p_provider_message_id:sent.data.id,p_error_class:null});return NextResponse.json({processed:true});
  }catch(error){await admin.rpc("finish_managed_email_send",{p_queue_message_id:job.queueMessageId,p_job_id:job.jobId,p_provider_message_id:null,p_error_class:error instanceof Error?error.constructor.name:"UnknownError"});return NextResponse.json({error:"Delivery will retry"},{status:503});}
}

