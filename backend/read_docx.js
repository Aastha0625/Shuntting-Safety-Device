const mammoth = require("mammoth");
const fs = require("fs");
const path = require("path");

const docxPath = "d:\\OneDrive\\Desktop\\RailScooter\\Shunting_Safety_Product_Requirement_Document.docx";
const outPath = path.join(__dirname, "prd.txt");

mammoth.extractRawText({path: docxPath})
    .then(function(result){
        fs.writeFileSync(outPath, result.value);
        console.log("Extracted successfully!");
    })
    .catch(console.error);
