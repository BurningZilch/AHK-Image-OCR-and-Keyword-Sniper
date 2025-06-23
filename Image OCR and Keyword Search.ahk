#Requires AutoHotkey v2.0
#Include <Gdip_All>

; ——————————————————————————————————————————————————————————————————————————————————————————————————
; ——— Configuration ———
; ——————————————————————————————————————————————————————————————————————————————————————————————————

global TESSERACT_PATH := "tesseract" ; Path to your Tesseract executable
global FFMPEG_PATH := "ffmpeg"       ; Path to your FFmpeg executable
global SCREENSHOTS_FOLDER := A_ScriptDir "\Screenshots\"
global OCR_RESULT_FOLDER := A_ScriptDir "\OcrResults\"
global OCR_LANGUAGE := "chi_sim"     ; Tesseract language for OCR (Simplified Chinese)
global NEXT_PAGE_KEY := "a" 	     ;
global MAX_LOOP := 500
global SEARCH_KEYWORDS := ["冰","雪","少女", "日落"]        ; Add more as needed
global IGNORE_KEYWORDS := ["冰河", "雪月花", "永雪"]         ; Add more as needed
global FIXED_NUMBER := 1    ; If FIXED_NUMBER more keywords than ignores, stop

; ——— Screen Capture Area ———
global CAPTURE_X := 380
global CAPTURE_Y := 290
global CAPTURE_W := 200
global CAPTURE_H := 310

SelectCaptureArea()

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

if !DirExist(OCR_RESULT_FOLDER) {
    DirCreate OCR_RESULT_FOLDER
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
        Send NEXT_PAGE_KEY
        Sleep 100

        fileName := CaptureScreenArea(CAPTURE_X, CAPTURE_Y, CAPTURE_W, CAPTURE_H)
        originalImagePath := SCREENSHOTS_FOLDER . fileName

        processedImagePath := SCREENSHOTS_FOLDER . "processed_" . fileName
        PreprocessImage(originalImagePath, processedImagePath)

        ocrText := PerformOCR(processedImagePath)

	; Save OCR result to a file
	txtFileName := StrReplace(fileName, ".png", ".txt")
	ocrTextPath := OCR_RESULT_FOLDER . txtFileName
	FileAppend ocrText, ocrTextPath, "UTF-8"


        FileDelete originalImagePath

        ; Count keyword hits
        totalKeywordCount := 0
        for each, kw in SEARCH_KEYWORDS {
            totalKeywordCount += CountOccurrences(ocrText, kw)
        }

        totalIgnoreCount := 0
        for each, kw in IGNORE_KEYWORDS {
            totalIgnoreCount += CountOccurrences(ocrText, kw)
        }

        if (totalKeywordCount >= totalIgnoreCount + FIXED_NUMBER) {
            SoundBeep 1000, 200
            MsgBox "Keyword found!", "Success", "T0.5"
            return
        }
    }
    SoundBeep 500, 200
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

CountOccurrences(text, keyword) {
    count := 0
    pos := 1
    while (pos := InStr(text, keyword, false, pos)) {
        count++
        pos += StrLen(keyword)  ; Move past the matched keyword to avoid overlapping
    }

    return count
}

SelectCaptureArea() {
    global CAPTURE_X, CAPTURE_Y, CAPTURE_W, CAPTURE_H
    CoordMode("Mouse", "Screen") 
    MsgBox "Please move your mouse to the **top-left corner** of the area and press Ctrl"
    ; Wait for Ctrl key press
    KeyWait "Ctrl", "D"  ; Wait for Ctrl to be *pressed down*
    MouseGetPos &x1, &y1

    MsgBox "Top-left corner captured at: " x1 "," y1 "`nNow move to the **bottom-right corner** and press Ctrl again"
    KeyWait "Ctrl", "D"
    MouseGetPos &x2, &y2

    ; Calculate coordinates and size
    CAPTURE_X := Min(x1, x2)
    CAPTURE_Y := Min(y1, y2)
    CAPTURE_W := Abs(x2 - x1)
    CAPTURE_H := Abs(y2 - y1)

    MsgBox "Capture Area Set:`nX: " CAPTURE_X "`nY: " CAPTURE_Y "`nW: " CAPTURE_W "`nH: " CAPTURE_H
}

; ——————————————————————————————————————————————————————————————————————————————————————————————————
; ——— Exit Routine ———
; ——————————————————————————————————————————————————————————————————————————————————————————————————

Shutdown(*) {
    global pToken
    Gdip_Shutdown(pToken)
    ExitApp()
}
