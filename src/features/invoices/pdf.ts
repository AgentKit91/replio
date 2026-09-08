import {PDFDocument,StandardFonts,rgb} from "pdf-lib";

export type InvoicePdfInput={invoiceNumber:string;issueDate:string;dueDate:string;currency:string;issuer:{legalName:string;tradingName?:string|null;address:string;email:string;registrationNumber?:string|null;taxNumber?:string|null;bankDetails?:string|null};customer:{name:string;address?:string|null;purchaseOrder?:string|null};items:Array<{description:string;quantity:number;unitAmountMinor:number;lineTotalMinor:number}>;subtotalMinor:number;taxMinor:number;totalMinor:number;notes?:string|null};

const money=(minor:number,currency:string)=>new Intl.NumberFormat("en-GB",{style:"currency",currency,currencyDisplay:"code"}).format(minor/100);
const clean=(value:string)=>value.replace(/[^\x20-\x7e\n]/g,"-").trim();
const lines=(text:string,max=78)=>clean(text).split(/\r?\n/).flatMap(paragraph=>{const words=paragraph.split(/\s+/);const out:string[]=[];let line="";for(const word of words){if(!word)continue;const next=line?`${line} ${word}`:word;if(next.length>max){if(line)out.push(line);line=word;}else line=next;}out.push(line);return out;});

export async function renderInvoicePdf(input:InvoicePdfInput){
  const pdf=await PDFDocument.create();const font=await pdf.embedFont(StandardFonts.Helvetica);const bold=await pdf.embedFont(StandardFonts.HelveticaBold);const page=pdf.addPage([595.28,841.89]);const {width,height}=page.getSize();
  pdf.setTitle(`Invoice ${input.invoiceNumber}`);pdf.setAuthor("Rep Bureau");pdf.setSubject("Creator commercial invoice");const fixed=new Date(`${input.issueDate}T00:00:00.000Z`);pdf.setCreationDate(fixed);pdf.setModificationDate(fixed);
  const ink=rgb(0.08,0.1,0.14),muted=rgb(0.38,0.42,0.48),accent=rgb(0.23,0.18,0.78);let y=height-62;
  const draw=(text:string,x:number,size=10,face=font,color=ink)=>page.drawText(clean(text),{x,y,size,font:face,color});
  draw("REP BUREAU",48,12,bold,accent);page.drawText("INVOICE",{x:width-145,y,size:24,font:bold,color:ink});y-=42;
  draw(input.issuer.tradingName||input.issuer.legalName,48,15,bold);page.drawText(input.invoiceNumber,{x:width-190,y,size:12,font:bold,color:ink});y-=18;
  for(const line of lines(input.issuer.address,42)){draw(line,48,9,font,muted);y-=12;}draw(input.issuer.email,48,9,font,muted);y-=12;if(input.issuer.registrationNumber){draw(`Registration: ${input.issuer.registrationNumber}`,48,9,font,muted);y-=12;}if(input.issuer.taxNumber){draw(`Tax number: ${input.issuer.taxNumber}`,48,9,font,muted);y-=12;}y-=22;
  draw("BILL TO",48,9,bold,muted);draw("ISSUED",330,9,bold,muted);page.drawText(input.issueDate,{x:420,y,size:9,font,color:ink});y-=16;
  draw(input.customer.name,48,11,bold);draw("DUE",330,9,bold,muted);page.drawText(input.dueDate,{x:420,y,size:9,font,color:ink});y-=16;
  for(const line of lines(input.customer.address||"Address not supplied",42)){draw(line,48,9,font,muted);y-=12;}if(input.customer.purchaseOrder){draw(`PO: ${input.customer.purchaseOrder}`,48,9,font,ink);y-=14;}y-=24;
  page.drawRectangle({x:48,y:y-8,width:width-96,height:28,color:rgb(.95,.95,.98)});draw("DESCRIPTION",58,9,bold,muted);page.drawText("QTY",{x:350,y,size:9,font:bold,color:muted});page.drawText("RATE",{x:405,y,size:9,font:bold,color:muted});page.drawText("AMOUNT",{x:490,y,size:9,font:bold,color:muted});y-=28;
  for(const item of input.items){for(const [index,line] of lines(item.description,44).entries()){draw(line,58,9);if(index===0){page.drawText(String(item.quantity),{x:350,y,size:9,font,color:ink});page.drawText(money(item.unitAmountMinor,input.currency),{x:405,y,size:9,font,color:ink});page.drawText(money(item.lineTotalMinor,input.currency),{x:490,y,size:9,font,color:ink});}y-=14;}y-=8;}
  y-=12;page.drawLine({start:{x:330,y},end:{x:547,y},thickness:1,color:rgb(.82,.83,.87)});y-=22;draw("Subtotal",350,9,font,muted);page.drawText(money(input.subtotalMinor,input.currency),{x:470,y,size:9,font,color:ink});y-=18;draw("Tax",350,9,font,muted);page.drawText(money(input.taxMinor,input.currency),{x:470,y,size:9,font,color:ink});y-=24;draw("TOTAL",350,11,bold);page.drawText(money(input.totalMinor,input.currency),{x:470,y,size:11,font:bold,color:accent});
  y=Math.min(y-54,190);draw("PAYMENT DETAILS",48,9,bold,muted);y-=16;for(const line of lines(input.issuer.bankDetails||"Payment details available from the issuer.",78)){draw(line,48,9);y-=13;}if(input.notes){y-=12;draw("NOTES",48,9,bold,muted);y-=16;for(const line of lines(input.notes,78)){draw(line,48,9);y-=13;}}
  page.drawText("Prepared by Rep Bureau. Reviewed and approved by the creator before sending.",{x:48,y:38,size:8,font,color:muted});page.drawText("1 / 1",{x:515,y:38,size:8,font,color:muted});
  return pdf.save({useObjectStreams:false,addDefaultPage:false});
}
