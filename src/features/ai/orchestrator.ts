import "server-only";
import { createHash } from "node:crypto";
import type { SupabaseClient } from "@supabase/supabase-js";
import { z } from "zod";
import { type AiGateway } from "./gateway";
import { workerContracts, type WorkerName } from "./contracts";

type Message = { id: string; direction: "inbound"|"outbound"; subject: string; body_text: string; internal_date: string };
const order: WorkerName[] = ["commercial_extractor","pricing_engine","risk_engine","strategy_engine","reply_engine"];
const instructions: Record<WorkerName,string> = {
  commercial_extractor:"Extract only facts supported by the supplied selected-thread messages. Mark absent material terms missing. Every confirmed fact needs short evidence.",
  pricing_engine:"Return three distinct fee recommendations. Use only supplied extracted facts; call out missing material inputs. Do not invent benchmarks.",
  risk_engine:"Prioritise material commercial risks and clarification needs. This is commercial guidance, not legal advice.",
  strategy_engine:"Return a concise negotiation sequence. Respect missing facts and never make the final accept or decline decision.",
  reply_engine:"Draft one concise editable reply. Use no fabricated facts or leverage and preserve the supplied commercial strategy.",
};

export async function runDealAnalysis(input:{ admin:SupabaseClient; gateway:AiGateway; snapshotId:string; workspaceId:string; dealId:string; userId:string; messages:Message[] }) {
  const combined:Record<string,unknown>={};
  const { data: prior } = await input.admin.from("ai_worker_runs").select("worker_name,output,state").eq("snapshot_id",input.snapshotId).eq("state","completed");
  for(const run of prior??[]) if(run.output) combined[run.worker_name]=run.output;
  for(const worker of order){
    if(combined[worker]) continue;
    const context = worker==="commercial_extractor" ? { messages:input.messages } : worker==="pricing_engine" ? { extraction:combined.commercial_extractor } : worker==="risk_engine" ? { extraction:combined.commercial_extractor } : worker==="strategy_engine" ? { extraction:combined.commercial_extractor,pricing:combined.pricing_engine,risks:combined.risk_engine } : { messages:input.messages,strategy:combined.strategy_engine,risks:combined.risk_engine };
    const prompt=JSON.stringify(context); const inputHash=createHash("sha256").update(prompt).digest("hex"); const started=Date.now();
    await input.admin.from("ai_worker_runs").upsert({workspace_id:input.workspaceId,snapshot_id:input.snapshotId,worker_name:worker,worker_version:1,input_hash:inputHash,state:"running",started_at:new Date().toISOString()},{onConflict:"snapshot_id,worker_name,worker_version"});
    try{
      const result=await input.gateway.run({worker,schema:workerContracts[worker] as z.ZodType<unknown>,system:`You are Replio's ${worker}. ${instructions[worker]} Return structured output only. Never reveal hidden reasoning.`,prompt,userId:input.userId,maxOutputTokens:worker==="reply_engine"?1200:1800});
      combined[worker]=result.output;
      await input.admin.from("ai_worker_runs").update({provider:result.provider,model_id:result.model,state:"completed",output:result.output,input_tokens:result.inputTokens,output_tokens:result.outputTokens,estimated_cost_microunits:result.estimatedCostMicrounits,latency_ms:result.latencyMs,completed_at:new Date().toISOString(),error_class:null}).eq("snapshot_id",input.snapshotId).eq("worker_name",worker);
      await input.admin.from("analysis_snapshots").update({state:"partial",structured_output:combined}).eq("id",input.snapshotId);
    }catch(error){
      const errorClass=error instanceof Error ? error.constructor.name.slice(0,80) : "UnknownError";
      await input.admin.from("ai_worker_runs").update({state:"failed",latency_ms:Date.now()-started,error_class:errorClass,completed_at:new Date().toISOString()}).eq("snapshot_id",input.snapshotId).eq("worker_name",worker); throw error;
    }
  }
  return combined;
}
