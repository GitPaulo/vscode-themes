#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const THEMES_DIR = path.join(__dirname, '..', 'themes');
const SRC_DIR = path.join(__dirname, '..', 'src');
const BASE_FILE = path.join(SRC_DIR, 'base', 'vscode-colors.json');

function readWithComments(filePath) {
  return fs.readFileSync(filePath, 'utf8');
}

function mergeJSONCFiles(metadataContent, baseColorsContent, syntaxContent) {
  // Simple text-based merge that preserves all comments
  const lines = [];

  // Add metadata (everything except closing brace)
  const metadataLines = metadataContent.trim().split('\n');
  const metadataWithoutClosing = metadataLines.slice(0, -1);
  // Add comma to last line if it doesn't have one
  const lastMetadataLine = metadataWithoutClosing[metadataWithoutClosing.length - 1];
  if (lastMetadataLine && !lastMetadataLine.trim().endsWith(',')) {
    metadataWithoutClosing[metadataWithoutClosing.length - 1] = lastMetadataLine + ',';
  }
  lines.push(...metadataWithoutClosing);

  // Add base colors (everything except opening/closing braces)
  const baseLines = baseColorsContent.trim().split('\n');
  const baseWithoutBraces = baseLines.slice(1, -1);
  // Add comma to last line if it doesn't have one
  const lastBaseLine = baseWithoutBraces[baseWithoutBraces.length - 1];
  if (lastBaseLine && !lastBaseLine.trim().endsWith(',')) {
    baseWithoutBraces[baseWithoutBraces.length - 1] = lastBaseLine + ',';
  }
  lines.push('');
  lines.push(...baseWithoutBraces);

  // Add syntax (everything except opening brace)
  const syntaxLines = syntaxContent.trim().split('\n');
  lines.push('');
  lines.push(...syntaxLines.slice(1)); // Remove {, keep }

  return lines.join('\n');
}

function buildTheme(themeName) {
  console.log(`Building: ${themeName}`);

  const themeDir = path.join(SRC_DIR, themeName);
  const metadataFile = path.join(themeDir, 'metadata.json');
  const syntaxFile = path.join(themeDir, 'syntax.json');
  const outputFile = path.join(THEMES_DIR, `gitpaulo_${themeName}.json`);

  // Read all files with comments preserved
  const metadata = readWithComments(metadataFile);
  const baseColors = readWithComments(BASE_FILE);
  const syntax = readWithComments(syntaxFile);

  // Merge files
  const merged = mergeJSONCFiles(metadata, baseColors, syntax);

  // Write output
  fs.writeFileSync(outputFile, merged, 'utf8');
  console.log(`  ✅ ${outputFile}`);
}

function main() {
  console.log('🔨 Building themes...\n');

  if (!fs.existsSync(BASE_FILE)) {
    console.error(`❌ Base file not found: ${BASE_FILE}`);
    process.exit(1);
  }

  // Auto-discover themes from src/ directory (exclude base/)
  const themes = fs.readdirSync(SRC_DIR, { withFileTypes: true })
    .filter(dirent => dirent.isDirectory() && dirent.name !== 'base')
    .map(dirent => dirent.name);

  if (themes.length === 0) {
    console.error('❌ No themes found in src/');
    process.exit(1);
  }

  // Build each theme
  for (const theme of themes) {
    try {
      buildTheme(theme);
    } catch (error) {
      console.error(`❌ Error building ${theme}: ${error.message}`);
      process.exit(1);
    }
  }

  console.log(`\n✨ Built ${themes.length} theme(s)`);
}

main();
