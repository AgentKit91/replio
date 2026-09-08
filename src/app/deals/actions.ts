"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { z } from "zod";
import { requireUser } from "@/features/auth/require-user";
import { dealStates } from "@/features/deals/state";
import { replyRewriteOutput } from "@/features/ai/contracts";
import { VercelAiGateway } from "@/features/ai/gateway";
import {ensureInvoicePdf} from "@/features/invoices/ensure-pdf";

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
  }catch{return {ok:false,message:"Rep Bureau could not rewrite this draft. Your current wording is unchanged."};}
}

const moneySchema=z.string().trim().regex(/^\d+(?:\.\d{1,2})?$/).transform((value)=>{const [whole,fraction=""]=value.split(".");return BigInt(whole)*BigInt(100)+BigInt(fraction.padEnd(2,"0"));}).refine((value)=>value<=BigInt(Number.MAX_SAFE_INTEGER));
export async function completeDealOutcome(formData:FormData){
  const dealId=idSchema.parse(formData.get("dealId"));const outcome=z.enum(["success","lost","declined"]).parse(formData.get("outcome"));const finalAmount=moneySchema.parse(formData.get("finalAmount"));const rounds=z.coerce.number().int().min(0).max(100).parse(formData.get("rounds"));
  const improvements=z.string().max(5000).parse(formData.get("improvements")??"").split("\n").map((item)=>item.trim()).filter(Boolean).slice(0,30);
  const learning=z.string().trim().max(5000).parse(formData.get("learning")??"");const {supabase}=await requireUser();
  const {error}=await supabase.rpc("complete_deal_outcome",{p_deal_id:dealId,p_outcome:outcome,p_final_amount_minor:Number(finalAmount),p_negotiation_rounds:rounds,p_major_term_improvements:improvements,p_contextual_learning:learning?{creator_note:learning}:{}});
  if(error)throw new Error("Unable to complete this Deal.");revalidatePath(`/deals/${dealId}`);revalidatePath("/deals");revalidatePath("/insights");revalidatePath("/dashboard");
}

const operationalFactSchema=z.object({dealId:z.uuid(),fieldKey:z.enum(["brand_name","agency_name","contact_name","contact_email","billing_entity","billing_address","accounts_payable_email","purchase_order","invoice_instructions","campaign_start","campaign_end","usage_terms","exclusivity_terms","paid_media_terms"]),displayValue:z.string().trim().min(1).max(5000)});
export async function saveOperationalFact(formData:FormData){
  const value=operationalFactSchema.parse({dealId:formData.get("dealId"),fieldKey:formData.get("fieldKey"),displayValue:formData.get("displayValue")});
  const {supabase}=await requireUser();const {error}=await supabase.rpc("set_deal_operational_fact",{p_deal_id:value.dealId,p_field_key:value.fieldKey,p_value:{text:value.displayValue},p_display_value:value.displayValue});
  if(error)throw new Error("Unable to save this Deal fact.");revalidatePath(`/deals/${value.dealId}`);revalidatePath("/dashboard");
}

export async function prepareInvoice(formData:FormData){
  const dealId=idSchema.parse(formData.get("dealId"));const {supabase}=await requireUser();const {error}=await supabase.rpc("prepare_deal_invoice",{p_deal_id:dealId});
  if(error)throw new Error("Add an invoice issuer profile and final agreed fee before preparing the invoice.");revalidatePath(`/deals/${dealId}`);revalidatePath("/dashboard");
}

export async function finaliseInvoice(formData:FormData){
  const value=z.object({dealId:z.uuid(),invoiceId:z.uuid(),expectedTotal:z.coerce.number().int().nonnegative()}).parse({dealId:formData.get("dealId"),invoiceId:formData.get("invoiceId"),expectedTotal:formData.get("expectedTotal")});
  const {supabase}=await requireUser();const {error}=await supabase.rpc("finalise_invoice",{p_invoice_id:value.invoiceId,p_expected_total_minor:value.expectedTotal});
  if(error)throw new Error("The invoice changed or is not ready for final review.");await ensureInvoicePdf(supabase,value.invoiceId);revalidatePath(`/deals/${value.dealId}`);revalidatePath("/dashboard");
}

export async function generateInvoicePdf(formData:FormData){const value=z.object({dealId:z.uuid(),invoiceId:z.uuid()}).parse({dealId:formData.get("dealId"),invoiceId:formData.get("invoiceId")});const {supabase}=await requireUser();await ensureInvoicePdf(supabase,value.invoiceId);revalidatePath(`/deals/${value.dealId}`);}

export async function confirmInvoicePaid(formData:FormData){
  const value=z.object({dealId:z.uuid(),invoiceId:z.uuid(),confirmation:z.literal("confirmed")}).parse({dealId:formData.get("dealId"),invoiceId:formData.get("invoiceId"),confirmation:formData.get("confirmation")});
  const {supabase}=await requireUser();const {error}=await supabase.rpc("confirm_invoice_paid",{p_invoice_id:value.invoiceId});
  if(error)throw new Error("Payment could not be confirmed.");revalidatePath(`/deals/${value.dealId}`);revalidatePath("/dashboard");revalidatePath("/insights");
}

export async function prepareInvoiceEmail(formData:FormData){
  const value=z.object({dealId:z.uuid(),invoiceId:z.uuid()}).parse({dealId:formData.get("dealId"),invoiceId:formData.get("invoiceId")});
  const {supabase}=await requireUser();const {error}=await supabase.rpc("prepare_invoice_email",{p_invoice_id:value.invoiceId,p_provider_route:"managed_email"});
  if(error)throw new Error("Review the accounts payable email and make sure the invoice PDF is ready.");revalidatePath(`/deals/${value.dealId}`);
}

export async function preparePaymentChaseEmail(formData:FormData){
  const value=z.object({dealId:z.uuid(),reminderId:z.uuid()}).parse({dealId:formData.get("dealId"),reminderId:formData.get("reminderId")});
  const {supabase}=await requireUser();const {error}=await supabase.rpc("prepare_payment_chase_email",{p_reminder_id:value.reminderId,p_provider_route:"managed_email"});
  if(error)throw new Error("The payment reminder could not be prepared.");revalidatePath(`/deals/${value.dealId}`);
}

export async function approveManagedAdminEmail(formData:FormData){
  const value=z.object({dealId:z.uuid(),draftId:z.uuid(),expectedVersion:z.coerce.number().int().positive(),confirmation:z.literal("send")}).parse({dealId:formData.get("dealId"),draftId:formData.get("draftId"),expectedVersion:formData.get("expectedVersion"),confirmation:formData.get("confirmation")});
  const {supabase}=await requireUser();
  const {error}=await supabase.rpc("approve_managed_email_send",{p_draft_id:value.draftId,p_expected_version:value.expectedVersion,p_confirmation:true});
  if(error)throw new Error("The draft changed or the recipient is no longer safe. Review it again.");revalidatePath(`/deals/${value.dealId}`);revalidatePath("/dashboard");
}

export async function saveDealDeadline(formData:FormData){
  const value=z.object({dealId:z.uuid(),deadlineId:z.union([z.literal(""),z.uuid()]),deadlineType:z.enum(["campaign_start","campaign_end","draft_due","approval_due","publish_due","invoice_due","payment_due","other"]),label:z.string().trim().min(1).max(200),dueAt:z.iso.datetime({local:true}),status:z.enum(["open","completed","cancelled"])}).parse({dealId:formData.get("dealId"),deadlineId:formData.get("deadlineId")??"",deadlineType:formData.get("deadlineType"),label:formData.get("label"),dueAt:formData.get("dueAt"),status:formData.get("status")??"open"});
  const {supabase}=await requireUser();const {error}=await supabase.rpc("save_deal_deadline",{p_deal_id:value.dealId,p_deadline_id:value.deadlineId||null,p_deadline_type:value.deadlineType,p_label:value.label,p_due_at:new Date(value.dueAt).toISOString(),p_status:value.status});
  if(error)throw new Error("Unable to save this deadline.");revalidatePath(`/deals/${value.dealId}`);revalidatePath("/dashboard");
}

export async function saveDealContract(formData:FormData){
  const value=z.object({dealId:z.uuid(),receivedStatus:z.enum(["not_received","received","not_applicable"]),signatureStatus:z.enum(["not_signed","creator_signed","fully_signed","not_applicable"]),reference:z.string().trim().max(500)}).parse({dealId:formData.get("dealId"),receivedStatus:formData.get("receivedStatus"),signatureStatus:formData.get("signatureStatus"),reference:formData.get("reference")??""});
  const {supabase}=await requireUser();const {error}=await supabase.rpc("save_deal_contract_reference",{p_deal_id:value.dealId,p_received_status:value.receivedStatus,p_signature_status:value.signatureStatus,p_reference:value.reference});if(error)throw new Error("Unable to save the contract status.");revalidatePath(`/deals/${value.dealId}`);
}

const decimalQuantity=z.string().trim().regex(/^\d+(?:\.\d{1,3})?$/).transform(Number).refine(value=>value>0&&value<=1_000_000);
export async function updateDraftInvoice(formData:FormData){
  const value=z.object({dealId:z.uuid(),invoiceId:z.uuid(),billingEntity:z.string().trim().min(1).max(200),billingAddress:z.string().trim().max(2000),accountsPayableEmail:z.email(),purchaseOrder:z.string().trim().max(200),description:z.string().trim().min(1).max(500),quantity:decimalQuantity,unitAmount:moneySchema,taxAmount:moneySchema,paymentTermsDays:z.coerce.number().int().min(0).max(180)}).parse(Object.fromEntries(formData));
  const {supabase}=await requireUser();const {error}=await supabase.rpc("update_draft_invoice",{p_invoice_id:value.invoiceId,p_billing_entity:value.billingEntity,p_billing_address:value.billingAddress,p_accounts_payable_email:value.accountsPayableEmail,p_purchase_order:value.purchaseOrder,p_description:value.description,p_quantity:value.quantity,p_unit_amount_minor:Number(value.unitAmount),p_tax_minor:Number(value.taxAmount),p_payment_terms_days:value.paymentTermsDays});if(error)throw new Error("Unable to update the draft invoice.");revalidatePath(`/deals/${value.dealId}`);revalidatePath("/dashboard");
}

export async function updateAdminEmailDraft(formData:FormData){
  const value=z.object({dealId:z.uuid(),draftId:z.uuid(),expectedVersion:z.coerce.number().int().positive(),subject:z.string().trim().min(1).max(998),body:z.string().trim().min(1).max(100000)}).parse(Object.fromEntries(formData));const {supabase}=await requireUser();const {error}=await supabase.rpc("update_admin_email_draft",{p_draft_id:value.draftId,p_expected_version:value.expectedVersion,p_subject:value.subject,p_body:value.body});if(error)throw new Error("The email draft changed. Reload and review it again.");revalidatePath(`/deals/${value.dealId}`);
}

export async function recordInvoiceStillWaiting(formData:FormData){const value=z.object({dealId:z.uuid(),invoiceId:z.uuid()}).parse(Object.fromEntries(formData));const {supabase}=await requireUser();const {error}=await supabase.rpc("record_invoice_still_waiting",{p_invoice_id:value.invoiceId});if(error)throw new Error("Unable to record the payment check.");revalidatePath(`/deals/${value.dealId}`);revalidatePath("/dashboard");}

export async function writeOffInvoice(formData:FormData){const value=z.object({dealId:z.uuid(),invoiceId:z.uuid(),confirmation:z.literal("write-off")}).parse(Object.fromEntries(formData));const {supabase}=await requireUser();const {error}=await supabase.rpc("write_off_invoice",{p_invoice_id:value.invoiceId,p_confirmation:true});if(error)throw new Error("Unable to write off this invoice.");revalidatePath(`/deals/${value.dealId}`);revalidatePath("/dashboard");revalidatePath("/insights");}

