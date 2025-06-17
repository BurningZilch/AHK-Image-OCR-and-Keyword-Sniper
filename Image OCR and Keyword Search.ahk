#Requires AutoHotkey v2.0
#Include <Gdip_All>

; ——————————————————————————————————————————————————————————————————————————————————————————————————
; ——— Configuration ———
; ——————————————————————————————————————————————————————————————————————————————————————————————————

global TESSERACT_PATH := "tesseract" ; Path to your Tesseract executable
global FFMPEG_PATH := "ffmpeg"       ; Path to your FFmpeg executable
global SCREENSHOTS_FOLDER := A_ScriptDir "\Screenshots\"
global OCR_LANGUAGE := "chi_sim"     ; Tesseract language for OCR (Simplified Chinese)
global SEARCH_KEYWORD := "冰"        ; The keyword to search for in the OCR text
global NEXT_PAGE_KEY := "a" 	     ;
global MAX_LOOP := 30

; ——— Screen Capture Area ———
global CAPTURE_X := 340
global CAPTURE_Y := 260
global CAPTURE_W := 230
global CAPTURE_H := 380

; ——————————————————————————————————————————————————————————————————————————————————————————————————
; ——— Initialization ———
; ——————————————————————————————————————————————————————————————————————————————————————————————————

; Start GDI+ for screen capture
pToken := Gdip_Startup()
OnExit(Shutdown)

; Create the screenshots folder if it doesn't exist
if !DirExist(SCREENSHOTS_FOLDER) {
    DirCreate SCREENSHOTS_FOLDER
}

; ——————————————————————————————————————————————————————————————————————————————————————————————————
; ——— Hotkey ———
; ——————————————————————————————————————————————————————————————————————————————————————————————————

!z:: { ; Alt+Z to start the main process
    RunImageCheck()
}

; ——————————————————————————————————————————————————————————————————————————————————————————————————
; ——— Main Logic ———
; ——————————————————————————————————————————————————————————————————————————————————————————————————

RunImageCheck() {
    Loop MAX_LOOP {
        Send NEXT_PAGE_KEY ; Sends the 'a' key
        Sleep 200

        ; 1. Capture and save the designated screen area
        fileName := CaptureScreenArea(CAPTURE_X, CAPTURE_Y, CAPTURE_W, CAPTURE_H)
        originalImagePath := SCREENSHOTS_FOLDER . fileName
        
        ; 2. Preprocess the image (convert to grayscale and adjust contrast)
        processedImagePath := SCREENSHOTS_FOLDER . "processed_" . fileName
        PreprocessImage(originalImagePath, processedImagePath)

        ; 3. Perform OCR on the processed image
        ocrText := PerformOCR(processedImagePath)

        ; Debug: Show OCR result (remove this line after testing)
        ; MsgBox "OCR Result: " . ocrText, "Debug", "T2"

        ; 4. Search for the keyword in the OCR result
        if InStr(ocrText, SEARCH_KEYWORD) {
            SoundBeep 1000, 200 ; Higher pitch beep for success
            MsgBox "Keyword found!", "Success", "T0.5"
            return ; Exit the function and loop
        }
    }
    SoundBeep 500, 200 ; Lower pitch beep for failure
    MsgBox "Keyword not found after 30 attempts.", "Finished", "T1"
}

; ——————————————————————————————————————————————————————————————————————————————————————————————————
; ——— Core Functions ———
; ——————————————————————————————————————————————————————————————————————————————————————————————————

/**
 * Captures a specific area of the screen.
 * @param x - The x-coordinate of the top-left corner.
 * @param y - The y-coordinate of the top-left corner.
 * @param width - The width of the capture area.
 * @param height - The height of the capture area.
 * @returns The file name of the saved screenshot.
 */
CaptureScreenArea(x, y, width, height) {
    pBitmap := Gdip_BitmapFromScreen(x "|" y "|" width "|" height)
    fileName := A_YYYY "-" A_MM "-" A_DD "_" A_Hour A_Min A_Sec ".png"
    savePath := SCREENSHOTS_FOLDER . fileName
    Gdip_SaveBitmapToFile(pBitmap, savePath)
    Gdip_DisposeImage(pBitmap)
    return fileName
}

/**
 * Preprocesses an image using FFmpeg for better OCR results.
 * @param inputPath - The path to the original image.
 * @param outputPath - The path to save the processed image.
 */
PreprocessImage(inputPath, outputPath) {
    cmd := Format('"{1}" -y -i "{2}" -vf "format=gray,eq=contrast=2.0:brightness=0.1" "{3}"', FFMPEG_PATH, inputPath, outputPath)
    RunWait cmd, , "Hide"
}

/**
 * Performs OCR on an image using Tesseract.
 * @param imagePath - The path to the image file.
 * @returns The recognized text from the image.
 */
PerformOCR(imagePath) {
    try {
        ; Create a temporary file to store OCR output
        tempFile := A_Temp "\ocr_output_" . A_TickCount . ".txt"
        
        ; Run Tesseract with output to file
        cmd := Format('"{1}" "{2}" "{3}" -l {4} --psm 6 --oem 3 -c preserve_interword_spaces=1', 
                     TESSERACT_PATH, imagePath, StrReplace(tempFile, ".txt", ""), OCR_LANGUAGE)
        
        RunWait cmd, , "Hide"
        
        ; Read the output file (Tesseract automatically adds .txt extension)
        if FileExist(tempFile) {
            ocrResult := FileRead(tempFile, "UTF-8")
            FileDelete tempFile ; Clean up temp file
            return ocrResult
        } else {
            MsgBox "OCR output file not created. Check if Tesseract is properly installed and accessible."
            return ""
        }
    } catch Error as e {
        MsgBox "An error occurred during OCR: " . e.Message
        return ""
    }
}

; ——————————————————————————————————————————————————————————————————————————————————————————————————
; ——— Exit Routine ———
; ——————————————————————————————————————————————————————————————————————————————————————————————————

Shutdown(*) {
    global pToken
    Gdip_Shutdown(pToken)
    ExitApp()
}
