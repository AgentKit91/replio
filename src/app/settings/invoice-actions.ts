"use server";
import {revalidatePath} from "next/cache";
import {z} from "zod";
import {requireUser} from "@/features/auth/require-user";
import {serverEnv} from "@/lib/env.server";

const schema=z.object({legalName:z.string().trim().min(1).max(200),tradingName:z.string().trim().max(200),address:z.string().trim().min(1).max(2000),email:z.email(),registrationNumber:z.string().trim().max(100),taxNumber:z.string().trim().max(100),bankDetails:z.string().trim().max(2000),invoicePrefix:z.string().trim().toUpperCase().regex(/^[A-Z0-9-]{1,12}$/),paymentTermsDays:z.coerce.number().int().min(0).max(180)});
export async function saveInvoiceIssuerProfile(formData:FormData){
  const value=schema.parse({legalName:formData.get("legalName"),tradingName:formData.get("tradingName")??"",address:formData.get("address"),email:formData.get("email"),registrationNumber:formData.get("registrationNumber")??"",taxNumber:formData.get("taxNumber")??"",bankDetails:formData.get("bankDetails")??"",invoicePrefix:formData.get("invoicePrefix"),paymentTermsDays:formData.get("paymentTermsDays")});
  const {supabase}=await requireUser();const {data:membership,error:membershipError}=await supabase.from("workspace_members").select("workspace_id").single();if(membershipError||!membership)throw new Error("Workspace not found.");
  const {error}=await supabase.from("invoice_issuer_profiles").upsert({workspace_id:membership.workspace_id,legal_name:value.legalName,trading_name:value.tradingName||null,address:value.address,email:value.email,registration_number:value.registrationNumber||null,tax_number:value.taxNumber||null,bank_details:value.bankDetails||null,invoice_prefix:value.invoicePrefix,payment_terms_days:value.paymentTermsDays},{onConflict:"workspace_id"});
  if(error)throw new Error("Unable to save invoice details.");revalidatePath("/settings");revalidatePath("/dashboard");
}

export async function allocateManagedEmailAddress(){
  if(!serverEnv.MANAGED_EMAIL_DOMAIN)throw new Error("Managed email domain activation is pending.");const {supabase}=await requireUser();const {error}=await supabase.rpc("allocate_creator_email_address",{p_domain:serverEnv.MANAGED_EMAIL_DOMAIN});if(error)throw new Error("Unable to allocate your Rep Bureau address.");revalidatePath("/settings");
}

