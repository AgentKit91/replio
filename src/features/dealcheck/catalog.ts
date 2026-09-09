import {z} from "zod";
export const dealCheckPackKeySchema=z.enum(["pack_3","pack_10"]);export type DealCheckPackKey=z.infer<typeof dealCheckPackKeySchema>;
export const DEALCHECK_PACKS={pack_3:{credits:3,amountMinor:499,label:"3 DealChecks"},pack_10:{credits:10,amountMinor:999,label:"10 DealChecks"}} as const;
