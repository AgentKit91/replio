"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { z } from "zod";
import { requireUser } from "@/features/auth/require-user";
import { dealStates } from "@/features/deals/state";

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
