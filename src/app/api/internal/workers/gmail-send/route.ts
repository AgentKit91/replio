import {timingSafeEqual} from "node:crypto";
import {NextRequest,NextResponse} from "next/server";
import {z} from "zod";
import {refreshGmailAccessToken} from "@/features/gmail/api";
import {decryptRefreshToken} from "@/features/gmail/crypto";
import {buildThreadedReply} from "@/features/gmail/reply-message";
import {findSentMessage,sendGmailReply} from "@/features/gmail/send";
import {serverEnv} from "@/lib/env.server";
import {createAdminClient} from "@/lib/supabase/admin";

const jobSchema=z.object({queue_message_id:z.number(),job_id:z.uuid(),reply_draft_id:z.uuid(),reply_version:z.number().int().positive(),rfc822_message_id:z.string(),from_address:z.string(),to_address:z.string(),subject:z.string(),body:z.string(),provider_thread_id:z.string(),in_reply_to:z.string(),references:z.string().nullable().optional(),encrypted_refresh_token:z.string(),encryption_iv:z.string(),encryption_auth_tag:z.string(),key_version:z.string()});
function authorized(request:NextRequest){const expected=serverEnv.INTERNAL_JOB_SECRET;const supplied=request.headers.get("authorization")?.replace(/^Bearer\s+/i,"");if(!expected||!supplied)return false;const left=Buffer.from(expected);const right=Buffer.from(supplied);return left.length===right.length&&timingSafeEqual(left,right);}

export async function POST(request:NextRequest){
  if(!authorized(request))return NextResponse.json({error:"Unauthorized"},{status:401});
  if(!serverEnv.GOOGLE_CLIENT_ID||!serverEnv.GOOGLE_CLIENT_SECRET||!serverEnv.GMAIL_TOKEN_ENCRYPTION_KEY)return NextResponse.json({error:"Worker is not configured"},{status:503});
  const admin=createAdminClient();const claimed=await admin.rpc("claim_gmail_send");if(claimed.error)return NextResponse.json({error:"Queue claim failed"},{status:500});if(!claimed.data)return new NextResponse(null,{status:204});const job=jobSchema.parse(claimed.data);
  try{
    const refreshToken=decryptRefreshToken({ciphertext:job.encrypted_refresh_token,iv:job.encryption_iv,authTag:job.encryption_auth_tag},serverEnv.GMAIL_TOKEN_ENCRYPTION_KEY);
    const access=await refreshGmailAccessToken({refreshToken,clientId:serverEnv.GOOGLE_CLIENT_ID,clientSecret:serverEnv.GOOGLE_CLIENT_SECRET});
    const prior=await findSentMessage(access.access_token,job.rfc822_message_id);
    const sent=prior??await sendGmailReply(access.access_token,buildThreadedReply({from:job.from_address,to:job.to_address,subject:job.subject,body:job.body,threadId:job.provider_thread_id,messageId:job.rfc822_message_id,inReplyTo:job.in_reply_to,references:job.references??undefined}));
    const finished=await admin.rpc("finish_gmail_send",{p_queue_message_id:job.queue_message_id,p_job_id:job.job_id,p_provider_message_id:sent.id});if(finished.error)throw finished.error;
    return NextResponse.json({sent:true,reconciled:Boolean(prior)});
  }catch(error){const errorClass=error instanceof Error?error.constructor.name:"UnknownError";await admin.rpc("fail_gmail_send",{p_queue_message_id:job.queue_message_id,p_job_id:job.job_id,p_error_class:errorClass});return NextResponse.json({error:"Gmail send will retry"},{status:503});}
}
