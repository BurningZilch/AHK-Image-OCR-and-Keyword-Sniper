# AHK Image OCR and Keyword Sniper

This [AutoHotkey v2](https://www.autohotkey.com/) script automates the process of capturing a specific area of the screen, performing Optical Character Recognition (OCR) on the image, and "sniping" for specific keywords. If a keyword is found, it alerts the user and stops. Otherwise, it triggers a key press to move to the next item and tries again.

---

## 🚀 Features

- 📸 **Interactive Screen Capture**  
  Select screen region using your mouse and keyboard (no manual coordinates needed).

- 🎛 **Image Preprocessing**  
  Converts screenshot to high-contrast grayscale for better OCR accuracy.

- 🔎 **Fast OCR + Keyword Search**  
  Uses Tesseract to detect keywords in image content.

- 🔁 **Loop Automation**  
  Sends a key press (`NEXT_PAGE_KEY`) to go to the next image or page and repeats the process.

- 🔊 **Alerts**  
  Notifies you if the keyword is found or when it has completed all attempts.

---

## 📋 Prerequisites

Ensure the following are installed and available in your system's PATH:

1. [**AutoHotkey v2**](https://www.autohotkey.com/download/)
2. [**Tesseract OCR**](https://github.com/tesseract-ocr/tessdoc)
    - Make sure you install the required language data (`chi_sim`, `eng`, etc.)
3. [**FFmpeg**](https://ffmpeg.org/download.html)

---

## 🧭 Interactive Region Setup

When the script starts, it will prompt you to define the capture region:

1. Move your mouse to the **top-left corner** of the area you want to scan and press `Ctrl`.
2. Move your mouse to the **bottom-right corner** and press `Ctrl` again.
3. The capture area will be calculated and used for all future screenshots in the session.

No need to manually configure `CAPTURE_X`, `CAPTURE_Y`, etc.

---

## ⚙️ Configuration Options

You can configure these at the top of the script:

| Variable | Description |
|----------|-------------|
| `SEARCH_KEYWORDS` | Array of target keywords (e.g. `["冰", "少女"]`) |
| `IGNORE_KEYWORDS` | Array of keywords to exclude (e.g. `["冰河"]`) |
| `NEXT_PAGE_KEY` | Key to send after each loop (e.g. `"a"`) |
| `OCR_LANGUAGE` | Tesseract language (e.g. `"chi_sim"` for Simplified Chinese) |
| `TESSERACT_PATH`, `FFMPEG_PATH` | Optional full paths to executables |
| `MAX_LOOP` | How many times to try before giving up |

---

## ▶️ How to Run

1. Install all dependencies listed above.
2. Open and configure the script in your text editor (only if needed).
3. Run the script by double-clicking the `.ahk` file.
4. Press **Alt + Z** to begin scanning.
5. The script will prompt you to define the screen capture region interactively.

It will now:

- Press the configured key
- Take a screenshot of the selected area
- Preprocess the image
- Extract text using OCR
- Check for keyword hits
- Repeat or stop based on results

---

## 📂 Output Files

- Screenshots are saved to a `Screenshots\` folder under the script's directory.
- Preprocessed images are saved with `processed_` prefix.
- OCR temporary files are auto-deleted after each use.

---

## 📄 License

This project is licensed under the MIT License. See the LICENSE file for details.

---

## 💡 Example Use Case

Useful in games, documents, or any GUI where you're scanning pages or items repeatedly looking for keywords like item names, alerts, or Chinese characters.

---

> ✅ If you'd like to extend this script with GUI overlays, image logging, or support for multiple regions — feel free to ask!
