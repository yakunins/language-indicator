const fs = require("fs");
const path = require("path");
const sharp = require("sharp");

const inputDir = path.join(__dirname, "flags-svg");
const outputDir = path.join(__dirname, "flags-png");

// Default size, can be overridden via command line: node convert-svg-to-png.js 32 24
const width = parseInt(process.argv[2]) || 32;
const height = parseInt(process.argv[3]) || width;

async function convertSvgToPng() {
    // Create output directory if it doesn't exist
    if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir, { recursive: true });
    }

    const files = fs.readdirSync(inputDir).filter((f) => f.endsWith(".svg"));
    console.log(`Converting ${files.length} SVG files to PNG (${width}x${height})...`);

    let converted = 0;
    let failed = 0;

    for (const file of files) {
        const inputPath = path.join(inputDir, file);
        const outputPath = path.join(outputDir, file.replace(".svg", ".png"));

        try {
            await sharp(inputPath)
                .resize(width, height, { fit: "contain", background: { r: 0, g: 0, b: 0, alpha: 0 } })
                .png()
                .toFile(outputPath);
            converted++;
        } catch (err) {
            console.error(`Failed: ${file} - ${err.message}`);
            failed++;
        }
    }

    console.log(`Done! Converted: ${converted}, Failed: ${failed}`);
}

convertSvgToPng();
