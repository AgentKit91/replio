"use server";
import { revalidatePath } from "next/cache";
import { z } from "zod";
import { requireUser } from "@/features/auth/require-user";

const grantSchema=z.object({reason:z.string().trim().min(3).max(500),durationHours:z.coerce.number().int().refine(v=>[24,72,168].includes(v)),confirmation:z.literal("confirmed")});
export async function grantSupportAccess(formData:FormData){const v=grantSchema.parse({reason:formData.get("reason"),durationHours:formData.get("durationHours"),confirmation:formData.get("confirmation")});const {supabase,userId}=await requireUser();const {data:membership,error:membershipError}=await supabase.from("workspace_members").select("workspace_id").eq("user_id",userId).single();if(membershipError||!membership)throw new Error("Creator workspace is unavailable.");const expiresAt=new Date(Date.now()+v.durationHours*60*60*1000).toISOString();const {error}=await supabase.from("support_access_grants").insert({workspace_id:membership.workspace_id,granted_by_user_id:userId,scope_type:"workspace",reason:v.reason,expires_at:expiresAt});if(error)throw new Error("Support access was not granted.");revalidatePath("/settings");}
export async function revokeSupportAccess(formData:FormData){const id=z.string().uuid().parse(formData.get("grantId"));const {supabase}=await requireUser();const {error}=await supabase.from("support_access_grants").update({revoked_at:new Date().toISOString()}).eq("id",id).is("revoked_at",null);if(error)throw new Error("Support access was not revoked.");revalidatePath("/settings");}

