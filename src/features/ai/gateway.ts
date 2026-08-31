import "server-only";
import { gateway, generateText, Output } from "ai";
import { z } from "zod";

export interface AiRunResult<T> { output: T; provider: string; model: string; inputTokens: number; outputTokens: number; estimatedCostMicrounits: number | null; latencyMs: number; }
export interface AiGateway { run<T>(request: { worker: string; schema: z.ZodType<T>; system: string; prompt: string; userId: string; maxOutputTokens: number }): Promise<AiRunResult<T>>; }

export class VercelAiGateway implements AiGateway {
  constructor(private readonly model = process.env.AI_GATEWAY_MODEL) {}
  async run<T>({ worker, schema, system, prompt, userId, maxOutputTokens }: { worker: string; schema: z.ZodType<T>; system: string; prompt: string; userId: string; maxOutputTokens: number }): Promise<AiRunResult<T>> {
    if (!this.model) throw new Error("AI_GATEWAY_MODEL is not configured");
    if (Math.ceil(prompt.length / 4) > 12000) throw new Error("AI input exceeds the per-run budget");
    const started = Date.now();
    const fallbackModel=process.env.AI_GATEWAY_FALLBACK_MODEL;
    const result = await generateText({ model: this.model, system, prompt, maxOutputTokens, output: Output.object({ schema }), providerOptions: { gateway: { user: userId, tags: [`worker:${worker}`, `env:${process.env.APP_ENV ?? "development"}`], ...(fallbackModel?{models:[fallbackModel]}:{}) } } });
    const inputTokens = result.usage.inputTokens ?? 0; const outputTokens = result.usage.outputTokens ?? 0;
    const inputRate = Number(process.env.AI_INPUT_COST_MICRO_PER_MILLION); const outputRate = Number(process.env.AI_OUTPUT_COST_MICRO_PER_MILLION);
    let estimatedCostMicrounits = Number.isFinite(inputRate) && Number.isFinite(outputRate) ? Math.ceil((inputTokens * inputRate + outputTokens * outputRate) / 1_000_000) : null;
    const generationId=result.providerMetadata?.gateway?.generationId;
    if(typeof generationId==="string") try { const generation=await gateway.getGenerationInfo({id:generationId}); estimatedCostMicrounits=Math.ceil(generation.totalCost*1_000_000); } catch { /* Retain the configured rate estimate if generation lookup is briefly unavailable. */ }
    return { output: result.output, provider: "vercel-ai-gateway", model: this.model, inputTokens, outputTokens, estimatedCostMicrounits, latencyMs: Date.now() - started };
  }
}
