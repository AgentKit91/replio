import "server-only";
import { generateText, Output } from "ai";
import { z } from "zod";

export interface AiRunResult<T> { output: T; provider: string; model: string; inputTokens: number; outputTokens: number; latencyMs: number; }
export interface AiGateway { run<T>(request: { worker: string; schema: z.ZodType<T>; system: string; prompt: string; userId: string; maxOutputTokens: number }): Promise<AiRunResult<T>>; }

export class VercelAiGateway implements AiGateway {
  constructor(private readonly model = process.env.AI_GATEWAY_MODEL) {}
  async run<T>({ worker, schema, system, prompt, userId, maxOutputTokens }: { worker: string; schema: z.ZodType<T>; system: string; prompt: string; userId: string; maxOutputTokens: number }): Promise<AiRunResult<T>> {
    if (!this.model) throw new Error("AI_GATEWAY_MODEL is not configured");
    if (Math.ceil(prompt.length / 4) > 12000) throw new Error("AI input exceeds the per-run budget");
    const started = Date.now();
    const result = await generateText({ model: this.model, system, prompt, maxOutputTokens, output: Output.object({ schema }), providerOptions: { gateway: { user: userId, tags: [`worker:${worker}`, `env:${process.env.APP_ENV ?? "development"}`] } } });
    return { output: result.output, provider: "vercel-ai-gateway", model: this.model, inputTokens: result.usage.inputTokens ?? 0, outputTokens: result.usage.outputTokens ?? 0, latencyMs: Date.now() - started };
  }
}
