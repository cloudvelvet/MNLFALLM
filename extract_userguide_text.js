const fs = require("fs");
const path = require("path");
const { PDFParse } = require("./.pdf-tools/node_modules/pdf-parse");

const input = path.join(
  "MAPS 2기 패널_Data_CSV (1)",
  "학부모(1~6차)",
  "MAPS 2기패널(1-5차)_데이터 유저가이드.pdf"
);
const output = "maps_parent_userguide_text.txt";

async function main() {
  const parser = new PDFParse({ data: fs.readFileSync(input) });
  const result = await parser.getText();
  await parser.destroy();
  fs.writeFileSync(output, result.text, "utf8");
  console.log(`Wrote ${output} (${result.text.length} chars)`);
}

main().catch((error) => {
  console.error(error);
  process.exit(1);
});
