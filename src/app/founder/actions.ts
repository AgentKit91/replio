"use server";
import { revalidatePath } from "next/cache";
import { z } from "zod";
import { requireUser } from "@/features/auth/require-user";
import { createAdminClient } from "@/lib/supabase/admin";
const schema=z.object({key:z.enum(["ai_worker_enabled","gmail_send_enabled"]),enabled:z.enum(["true","false"]).transform(v=>v==="true"),expectedVersion:z.coerce.number().int().positive(),idempotencyKey:z.string().uuid(),confirmation:z.string().optional()});
export async function setWorkerControl(formData:FormData){const v=schema.parse({key:formData.get("key"),enabled:formData.get("enabled"),expectedVersion:formData.get("expectedVersion"),idempotencyKey:formData.get("idempotencyKey"),confirmation:formData.get("confirmation")});const confirmed=v.confirmation==="confirmed";if(v.enabled&&!confirmed)throw new Error("Confirm that you intend to resume this worker.");const {userId}=await requireUser();const {error}=await createAdminClient().rpc("founder_set_worker_control",{p_founder_user_id:userId,p_key:v.key,p_enabled:v.enabled,p_expected_version:v.expectedVersion,p_confirmation:confirmed,p_idempotency_key:v.idempotencyKey});if(error)throw new Error("The worker control was not changed. Refresh and try again.");revalidatePath("/founder");}

