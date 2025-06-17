# AHK Image OCR and Keyword Sniper

This AutoHotkey (AHK) v2 script automates the process of capturing a specific area of the screen, performing Optical Character Recognition (OCR) on the image, and "sniping" for a specific keyword. If the keyword is found, it alerts the user and stops. Otherwise, it triggers an action to move to the next item and tries again.

It's designed for repetitive tasks where you need to find a specific item in a list or sequence of images.

## 🚀 Features

-   **Targeted Screen Capture**: Captures a user-defined area of the screen.
-   **Image Preprocessing**: Automatically converts the screenshot to high-contrast grayscale to improve OCR accuracy.
-   **Fast OCR**: Uses the Tesseract engine to extract text directly from the image.
-   **Keyword Search**: Scans the extracted text for a specific keyword.
-   **Simple Automation**: Sends a key press to advance to the next item and repeats the process automatically.
-   **Easy to Configure**: All key variables (hotkey, keyword, screen area) are at the top of the script for easy editing.

## 📋 Prerequisites

Before you can run this script, you need to have the following software installed and configured:

1.  **[AutoHotkey v2](https://www.autohotkey.com/download/)**: You must be using version 2.0 or newer.

2.  **[Tesseract OCR](https://github.com/tesseract-ocr/tessdoc)**: Install Tesseract and **add its folder to your system's PATH** so it can be called from the command line.
    * During installation, make sure to select and install the language data you need (e.g., "Simplified Chinese" for `chi_sim`, "English" for `eng`).

3.  **[FFmpeg](https://ffmpeg.org/download.html)**: Install FFmpeg and **add its `bin` folder to your system's PATH**. This is required for image preprocessing.

## 🔧 Configuration

Open the script file in a text editor. All user-configurable settings are at the top in the **Configuration** section.

-   `SEARCH_KEYWORD`: The keyword you want the script to find.
-   `CAPTURE_X`, `CAPTURE_Y`, `CAPTURE_W`, `CAPTURE_H`: The coordinates (X, Y) and size (Width, Height) of the screen area to capture. You can use AHK's built-in "Window Spy" tool to find these values.
-   `OCR_LANGUAGE`: The Tesseract language code for the text you are trying to read.
-   `TESSERACT_PATH` and `FFMPEG_PATH`: You only need to edit these if Tesseract or FFmpeg are **not** in your system's PATH. In that case, provide the full path to the executable (e.g., `C:\Program Files\Tesseract-OCR\tesseract.exe`).

## ▶️ How to Run

1.  Ensure all prerequisites are installed and the library is in the correct location.
2.  Configure the script with your desired settings.
3.  Double-click the script file (`.ahk`) to run it. An icon will appear in your system tray.
4.  Navigate to the window or application you want to scan.
5.  Press **`Alt` + `Z`** to start the process.

The script will now repeatedly send the 'a' key, capture the screen, and check for your keyword. It will notify you when the keyword is found or when it has completed 30 attempts without success.

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.
