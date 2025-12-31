#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const jsonc = require('jsonc-parser');

function extractTheme(themeName) {
  console.log(`Extracting: ${themeName}...`);

  const themePath = path.join(__dirname, '..', 'themes', `.backup/gitpaulo_${themeName}.json`);
  const themeContent = fs.readFileSync(themePath, 'utf8');
  const theme = jsonc.parse(themeContent);

  // Extract metadata
  const metadata = {
    '$schema': theme['$schema'],
    'type': theme.type
  };
  if (theme.semanticHighlighting !== undefined) {
    metadata.semanticHighlighting = theme.semanticHighlighting;
  }

  // Extract syntax
  const syntax = {
    tokenColors: theme.tokenColors
  };
  if (theme.semanticTokenColors) {
    syntax.semanticTokenColors = theme.semanticTokenColors;
  }

  // Extract description
  const descPattern = /Syntax Token Colors[^\/]*\/\/\s*(.+)/;
  const match = themeContent.match(descPattern);
  if (match) {
    syntax._syntaxDescription = match[1].trim();
  }

  // Write files
  const srcDir = path.join(__dirname, '..', 'src', themeName);
  fs.mkdirSync(srcDir, { recursive: true });
  fs.writeFileSync(
    path.join(srcDir, 'metadata.json'),
    JSON.stringify(metadata, null, 2) + '\n'
  );
  fs.writeFileSync(
    path.join(srcDir, 'syntax.json'),
    JSON.stringify(syntax, null, 2) + '\n'
  );

  console.log(`  ✅ Created: src/${themeName}/metadata.json`);
  console.log(`  ✅ Created: src/${themeName}/syntax.json`);
}

const themes = ['github', 'tsoding', 'original', 'minimal', 'gruvbox'];

console.log('📦 Extracting theme-specific parts...\n');

themes.forEach(theme => {
  try {
    extractTheme(theme);
  } catch (error) {
    console.error(`❌ Error extracting ${theme}:`, error.message);
    process.exit(1);
  }
});

console.log('\n✨ All themes extracted successfully!');
