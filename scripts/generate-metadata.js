// generate-metadata.js
// Version: 3.8.0
// File: scripts/generate-metadata.js
// Description: TEST This script generates metadata.tex from config/DB

const metadata = "metadata-test.tex"

// generate-metadata.js - Version: 3.8.0

const fs = require("fs");

const config = JSON.parse(fs.readFileSync("config/config.json", "utf8"));
const datastore = JSON.parse(fs.readFileSync("data/datastore.json", "utf8"));

// Use first datastore entry (simulate single API pull; extend for batch)
const data = datastore[0] || {};

// Merge: Data overrides config
const merged = {
  tone: data.tone || config.template_settings.tone,
  use_letterhead: data.use_letterhead || config.template_settings.use_letterhead,
  use_signature: data.use_signature || config.template_settings.use_signature,
  multipage: data.multipage || config.template_settings.multipage,
  custom_date: data.custom_date || config.template_settings.custom_date,
  subject: data.subject || config.template_settings.subject,
  sender: { ...config.data_mappings.sender.db_map, ...(data.sender || {}) },
  recipient: { ...config.data_mappings.recipient.db_map, ...(data.recipient || {}) }
};

let output = `% Metadata Version: 3.8.0 - Generated from config/datastore\n\n`;

// Tone/context
output += `% Tone/context\n`;
output += `\\def\\tone{${merged.tone}}  % Set via config or database\n\n`;

// Images (from config; assume not in datastore)
output += `% LOGO, letterhead, signature images\n`;
output += `\\def\\logo{\\includegraphics[height=2.5em]{${config.image_paths.logo}}}\n`;
output += `\\def\\signatureimage{\\vspace*{1.5em}\\includegraphics[height=3.5em]{${config.image_paths.signature}}}\n\n`;

// Date
output += `% Date override\n`;
output += `\\def\\customdate{${merged.custom_date}}\n`;
output += `\\ifthenelse{\\equal{\\customdate}{}}{ \\date{\\today} }{ \\date{\\customdate} }\n\n`;

// Letterhead toggle/path
output += `% Letterhead/header setup\n`;
output += `\\def\\useletterhead{${merged.use_letterhead}}\n`;
output += `\\def\\letterheadpath{${config.image_paths.no_letterhead}}\n`;
output += `\\ifthenelse{\\equal{\\useletterhead}{yes}}{ \\def\\letterheadpath{${config.image_paths.letterhead}} }{}\n`;
output += `\\fancyhead[C]{\\includegraphics[height=5.0em,width=\\textwidth,keepaspectratio]{\\letterheadpath}}\n\n`;

// Sender details (mapped)
output += `% Sender details\n`;
for (const [dbKey, texKey] of Object.entries(config.data_mappings.sender.db_map)) {
  let value = merged.sender[dbKey] || "";
  if (dbKey === "address") value = value.replace(/\n/g, "\\\\");  // Multi-line
  output += `\\def\\${texKey}{${value}}\n`;
}
output += `\\address{\\textcolor{companyblue}{\\sender_fullname}\\\\ \\textcolor{companyblue}{City}\\\\ \\textcolor{companyblue}{Postcode}\\\\ \\textcolor{companygray}{Mobile: +123 456 7890}\\\\ \\textcolor{companygray}{Tel: +123 987 6543}\\\\ \\textcolor{companygray}{Email: joe@example.com}}\n`;
output += `\\signature{\\sender_fullname}\n`;
output += `\\telephone{+44 123 456789}\n\n`;

// Recipient details (mapped; similar)
output += `% Recipient details\n`;
for (const [dbKey, texKey] of Object.entries(config.data_mappings.recipient.db_map)) {
  let value = merged.recipient[dbKey] || "";
  if (dbKey === "address") value = value.replace(/\n/g, "\\\\");
  output += `\\def\\${texKey}{${value}}\n`;
}
output += `\\def\\recipientrawname{Doe, Jane}  % From database\n`;
output += `\\def\\recipientaddress{\\recipient_company\\\\ \\recipient_title\\ \\recipient_firstname\\ \\recipient_lastname\\ \\recipient_suffix\\\\456 Recipient Road\\\\Big Town \\linebreak  \\linebreak }\n\n`;

// Salutation, closing, etc. (use merged tone/subject; rest as before)
output += `% Construct salutation based on tone\n`;
output += `\\ifthenelse{\\equal{\\tone}{formal}}{ \\def\\salutation{Dear \\recipient_titleshort\\ \\recipient_lastname,} }{ \\ifthenelse{\\equal{\\tone}{informal}}{ \\def\\salutation{Dear \\recipient_firstname,} }{ \\def\\salutation{Dear Sir or Madam,} } }\n\n`;

// ... Add remaining sections (closing, opening redefine, signature setup, multipage, subject) similarly, using merged values.

fs.writeFileSync(metadata, output, "utf8");
console.log(`${metadata} generated from config and datastore`);