export const DEFAULT_BENCHMARK_MIN_SAMPLE=5;
export function benchmarkEvidence(sampleCount:number,minimum=DEFAULT_BENCHMARK_MIN_SAMPLE){
  if(!Number.isInteger(sampleCount)||sampleCount<0||!Number.isInteger(minimum)||minimum<2)throw new Error("Invalid benchmark evidence inputs");
  return {eligible:sampleCount>=minimum,strength:sampleCount>=Math.max(minimum*4,20)?"strong":sampleCount>=minimum?"emerging":"insufficient" as "strong"|"emerging"|"insufficient"};
}
