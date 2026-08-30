import { timingSafeEqual } from "node:crypto";
import { NextRequest, NextResponse } from "next/server";
import { z } from "zod";
import { VercelAiGateway } from "@/features/ai/gateway";
import { runDealAnalysis } from "@/features/ai/orchestrator";
import { serverEnv } from "@/lib/env.server";
import { createAdminClient } from "@/lib/supabase/admin";

const jobSchema=z.object({queue_message_id:z.number(),job_id:z.uuid(),snapshot_id:z.uuid(),workspace_id:z.uuid(),deal_id:z.uuid(),messages:z.array(z.object({id:z.uuid(),direction:z.enum(["inbound","outbound"]),subject:z.string(),body_text:z.string(),internal_date:z.string()}))});
function authorized(request:NextRequest){const expected=serverEnv.INTERNAL_JOB_SECRET;const supplied=request.headers.get("authorization")?.replace(/^Bearer\s+/i,"");if(!expected||!supplied)return false;const a=Buffer.from(expected),b=Buffer.from(supplied);return a.length===b.length&&timingSafeEqual(a,b);}
export async function POST(request:NextRequest){
  if(!authorized(request))return NextResponse.json({error:"Unauthorized"},{status:401});
  if(!serverEnv.AI_GATEWAY_MODEL)return NextResponse.json({error:"AI analysis is not activated"},{status:503});
  const admin=createAdminClient(); const {data,error}=await admin.rpc("claim_ai_analysis"); if(error)return NextResponse.json({error:"Queue claim failed"},{status:500}); if(!data)return new NextResponse(null,{status:204});
  const job=jobSchema.parse(data);
  try{
    const {data:member}=await admin.from("workspace_members").select("user_id").eq("workspace_id",job.workspace_id).limit(1).single(); if(!member)throw new Error("WorkspaceMemberMissing");
    const output=await runDealAnalysis({admin,gateway:new VercelAiGateway(serverEnv.AI_GATEWAY_MODEL),snapshotId:job.snapshot_id,workspaceId:job.workspace_id,dealId:job.deal_id,userId:member.user_id,messages:job.messages});
    await admin.from("analysis_snapshots").update({structured_output:output}).eq("id",job.snapshot_id);
    const {error:finishError}=await admin.rpc("finish_ai_analysis",{p_queue_message_id:job.queue_message_id,p_job_id:job.job_id,p_success:true,p_error_class:null}); if(finishError)throw finishError;
    return NextResponse.json({processed:true});
  }catch(error){const errorClass=error instanceof Error?error.constructor.name:"UnknownError";await admin.rpc("finish_ai_analysis",{p_queue_message_id:job.queue_message_id,p_job_id:job.job_id,p_success:false,p_error_class:errorClass});return NextResponse.json({error:"Analysis will retry"},{status:503});}
}
