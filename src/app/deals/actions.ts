"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { z } from "zod";
import { requireUser } from "@/features/auth/require-user";
import { dealStates } from "@/features/deals/state";
import { replyRewriteOutput } from "@/features/ai/contracts";
import { VercelAiGateway } from "@/features/ai/gateway";

const idSchema = z.string().uuid();
const stateSchema = z.enum(Object.keys(dealStates) as [keyof typeof dealStates, ...(keyof typeof dealStates)[]]);

export async function updateDealState(formData: FormData) {
  const dealId = idSchema.parse(formData.get("dealId"));
  const status = stateSchema.parse(formData.get("status"));
  const { supabase } = await requireUser();
  const { error } = await supabase.rpc("set_deal_state", { p_deal_id: dealId, p_status: status });
  if (error) throw new Error("Unable to update the deal state.");
  revalidatePath(`/deals/${dealId}`); revalidatePath("/deals");
}

export async function addDealNote(formData: FormData) {
  const dealId = idSchema.parse(formData.get("dealId"));
  const body = z.string().trim().min(1).max(10000).parse(formData.get("body"));
  const { supabase, userId } = await requireUser();
  const { data: deal, error: dealError } = await supabase.from("deals").select("workspace_id").eq("id", dealId).single();
  if (dealError || !deal) throw new Error("Deal not found.");
  const { error } = await supabase.from("deal_notes").insert({ workspace_id: deal.workspace_id, deal_id: dealId, body, created_by: userId });
  if (error) throw new Error("Unable to save the private note.");
  revalidatePath(`/deals/${dealId}`);
}

export async function recycleDeal(formData: FormData) {
  const dealId = idSchema.parse(formData.get("dealId"));
  const recycled = formData.get("recycled") === "true";
  const { supabase } = await requireUser();
  const { error } = await supabase.rpc("set_deal_recycled", { p_deal_id: dealId, p_recycled: recycled });
  if (error) throw new Error("Unable to update the recycle bin.");
  revalidatePath("/deals"); revalidatePath("/deals/recycle-bin");
  redirect(recycled ? "/deals" : `/deals/${dealId}`);
}

export async function requestDealAnalysis(formData: FormData) {
  const dealId = idSchema.parse(formData.get("dealId"));
  const { supabase } = await requireUser();
  const { error } = await supabase.rpc("request_deal_analysis", { p_deal_id: dealId });
  if (error) throw new Error("Unable to queue analysis.");
  revalidatePath(`/deals/${dealId}`);
}

const saveReplySchema=z.object({dealId:z.uuid(),subject:z.string().max(998),body:z.string().max(100000),expectedVersion:z.number().int().positive()});
export async function saveReplyDraft(input:z.infer<typeof saveReplySchema>):Promise<{ok:true;version:number}|{ok:false}> {
  const value=saveReplySchema.parse(input); const {supabase}=await requireUser();
  const {data,error}=await supabase.rpc("save_reply_draft",{p_deal_id:value.dealId,p_subject:value.subject,p_body:value.body,p_expected_version:value.expectedVersion});
  if(error||typeof data!=="number") return {ok:false}; revalidatePath(`/deals/${value.dealId}`); return {ok:true,version:data};
}
const queueReplySchema=z.object({dealId:z.uuid(),expectedVersion:z.number().int().positive(),acknowledgeChallenge:z.boolean().default(false)});
export async function queueReplySend(input:z.infer<typeof queueReplySchema>):Promise<{ok:boolean}> {
  const value=queueReplySchema.parse(input);const {supabase}=await requireUser();if(value.acknowledgeChallenge){const acknowledged=await supabase.rpc("acknowledge_reply_challenge",{p_deal_id:value.dealId});if(acknowledged.error)return {ok:false};}const {error}=await supabase.rpc("request_reply_send",{p_deal_id:value.dealId,p_expected_version:value.expectedVersion});if(error)return {ok:false};revalidatePath(`/deals/${value.dealId}`);return {ok:true};
}

const rewriteSchema=z.object({dealId:z.uuid(),expectedVersion:z.number().int().positive(),instruction:z.string().trim().min(1).max(500),startAgain:z.boolean()});
export async function rewriteReply(input:z.infer<typeof rewriteSchema>):Promise<{ok:true;body:string;version:number}|{ok:false;message:string}>{
  const value=rewriteSchema.parse(input);const {supabase,userId}=await requireUser();
  const {data:draft,error:draftError}=await supabase.from("reply_drafts").select("body,version,state,source_snapshot_id").eq("deal_id",value.dealId).maybeSingle();
  if(draftError||!draft||draft.state!=="draft"||draft.version!==value.expectedVersion)return {ok:false,message:"The draft changed. Reload before rewriting."};
  const {data:snapshot,error:snapshotError}=await supabase.from("analysis_snapshots").select("structured_output").eq("id",draft.source_snapshot_id).maybeSingle();
  if(snapshotError||!snapshot)return {ok:false,message:"The supporting analysis is unavailable."};
  try{
    const gateway=new VercelAiGateway();
    const result=await gateway.run({worker:"reply_rewrite",schema:replyRewriteOutput,system:"Rewrite one creator-controlled commercial email. Never invent facts, figures, leverage, deadlines, or agreement. Return only the rewritten body and a short change list. Preserve the current wording, creator edits, facts, and negotiation strategy unless start_again is true. Do not change the subject.",prompt:JSON.stringify({instruction:value.instruction,start_again:value.startAgain,current_body:draft.body,analysis:snapshot.structured_output}),userId,maxOutputTokens:1200});
    const {data:version,error}=await supabase.rpc("apply_reply_rewrite",{p_deal_id:value.dealId,p_body:result.output.body,p_expected_version:value.expectedVersion,p_instruction:value.instruction,p_start_again:value.startAgain});
    if(error||typeof version!=="number")return {ok:false,message:"The draft changed before the rewrite could be saved."};
    revalidatePath(`/deals/${value.dealId}`);return {ok:true,body:result.output.body,version};
  }catch{return {ok:false,message:"Replio could not rewrite this draft. Your current wording is unchanged."};}
}
