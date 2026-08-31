export type OutcomeTrendInput={
  outcome:"success"|"lost"|"declined";
  currency:string;
  final_amount_minor:number|null;
  estimated_additional_earnings_minor:number;
  negotiation_rounds:number|null;
};

function median(values:number[]){
  if(values.length===0)return null;
  const ordered=[...values].sort((a,b)=>a-b);const middle=Math.floor(ordered.length/2);
  return ordered.length%2===0?(ordered[middle-1]+ordered[middle])/2:ordered[middle];
}

export function calculatePersonalTrends(outcomes:OutcomeTrendInput[]){
  const completed=outcomes.length;const successes=outcomes.filter(item=>item.outcome==="success");
  const byCurrency=new Map<string,{count:number;finalMinor:number;eaeMinor:number}>();
  for(const item of outcomes){const current=byCurrency.get(item.currency)??{count:0,finalMinor:0,eaeMinor:0};current.count++;current.finalMinor+=item.final_amount_minor??0;current.eaeMinor+=item.estimated_additional_earnings_minor;byCurrency.set(item.currency,current);}
  return {
    completed,successes:successes.length,successRate:completed===0?null:(successes.length/completed)*100,
    medianUpliftMinor:median(outcomes.map(item=>item.estimated_additional_earnings_minor)),
    medianRounds:median(outcomes.flatMap(item=>item.negotiation_rounds===null?[]:[item.negotiation_rounds])),
    byCurrency:[...byCurrency.entries()].map(([currency,value])=>({currency,...value})).sort((a,b)=>a.currency.localeCompare(b.currency))
  };
}
