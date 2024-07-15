STD_OUTPUT_HANDLE EQU -11

CONSOLE_CURSOR_INFO STRUCT
    dwSize DWORD ?
    bVisible DWORD ?
CONSOLE_CURSOR_INFO ENDS

;-------------------------------------------
; Name: mDelay
; purpose: call Delay
; args: delayTime
; affect: NONE
; return: NONE
;-------------------------------------------
mDelay MACRO delayTime
    mov eax, delayTime
    call Delay
ENDM 

;-------------------------------------------
; Name: mWriteDec
; purpose: call WriteDec 
; args: integer
; affect: NONE
; return: NONE
;-------------------------------------------
mWriteDec MACRO integer
    mov eax, integer
    call WriteDec
ENDM

INCLUDE Irvine32.inc
INCLUDE macros.inc


.data
                                                   ;control cursor
    hConsoleOutput DWORD ?                  
    cursorInfo CONSOLE_CURSOR_INFO <>
                                                   ;for menu (1)

    menu_prompt BYTE "PRESS 1 for typing game, 2 for word dropping game and 3 for scoreBoard: ", 0   
    profile BYTE "Author: Kin Yin (Ben) Ho, CS066 ",0
    switchGame BYTE ?

    ;hover difficulty
    hoverLevel BYTE 1           
    gameStart BYTE "GAME ABOUT TO START IN", 0     ;loadingscreen stuff     
    dot BYTE ".", 0


    curX BYTE 0                                     ;for typing game (2)
    curY BYTE 0
    prevX BYTE 0                ;for backtracking
    prevY BYTE 0                ;for backtracking
    maxX BYTE ?     
    is_typing BYTE ?
    backtrack_Pilcrow BYTE 0    ;for backtracking
    Pilcrow_encounter BYTE 0
    paragraphBank BYTE 1000 DUP(?),0
    paragraphSize BYTE ?
    entered_bSpace BYTE 0
    return_main_menu BYTE 0
    one_minute_Timer DWORD 1
    Timer DWORD 60000


    arrXCords BYTE 30 DUP(0)                         ;for falling word game (3)
    arrYCords BYTE 30 DUP(0)
    should_Printed BYTE 30 DUP (1)

    finishLine BYTE 120 DUP("-"),0
    lineHeight BYTE 25
    isTouchLine BYTE 0

    wordsTyped DWORD 0
    wordsPrinted DWORD 1

    totalWords DWORD 0
    wordBank BYTE 500 DUP(?), 0
    
    inputArr BYTE 16 DUP(?)
    inputColor BYTE 16 DUP(?)
    outputArr BYTE 16 DUP(?)
    currentWord BYTE 0
    currentWordLength DWORD 0
    charsTyped DWORD 0
    error_count BYTE 0

    ;file reading business
    easy_mode BYTE "easy_mode.txt",0
    medium_mode BYTE "medium_mode.txt",0
    hard_mode BYTE "hard_mode.txt",0

    dict_4 BYTE "easy.txt", 0
    dict_8 BYTE "medium.txt", 0
    dict_12 BYTE "hard.txt", 0

    outputFile BYTE "output.txt",0

    bufsize = 7000 ;7000 bytes
    buffer BYTE bufsize DUP(?)
    fileHandle HANDLE ?
    stringLength DWORD ?
    bytesWritten DWORD ?
    newline BYTE 0Dh, 0Ah, 0

    ;accuracy & stuff
    mSec DWORD ?
    startTime DWORD ?
    endTime DWORD ?
    elapsedTime DWORD ?
    minutes DWORD ?
    seconds DWORD ?
    score DWORD 0
    Mistakes DWORD 0
    ACCURACY DWORD 0 
    isLost BYTE 0
    isWon BYTE 0
    WPM DWORD 0

    str_score BYTE 4 DUP(?),0
    msgLost BYTE "You lost! Try again", 0
    msgWon BYTE "You won!! ", 0
    msgMinutes BYTE " minutes(s) ", 0
    msgSeconds BYTE " second(s)",0
    msgTime BYTE "Time taken : ",0

    msgScore BYTE "Score: ", 0 
    msgWordsTyped BYTE "word Typed: ",0
    msgResult BYTE "Hey, There is your result! ",0
    max_name = 20
    resultCombined BYTE 30 DUP (?)
    String_Name BYTE max_name+1 DUP(?)
    isSave BYTE 1                          ;default saving this time
    totalInputCount DWORD 0


.code

;-------------------------------------------
; Name: openMenu
; purpose: purpose used to print the select difficulty menu
; args: hoverLevel
; affect: NONE
; return: NONE
;-------------------------------------------
openMenu PROC uses edx eax
    
    invoke GetStdHandle, STD_OUTPUT_HANDLE
    mov hConsoleOutput, eax

    mov cursorInfo.dwSize, 1
    mov cursorInfo.bVisible, 0
    invoke SetConsoleCursorInfo, hConsoleOutput, ADDR cursorInfo   ;hide cursor

    call printMenuText

    call GetMseconds
    mov msec, eax

    lookForKey:

        mDelay 100
        call ReadKey         ; look for keyboard input
        call GetMseconds

        .IF dx == VK_DOWN
            inc hoverLevel

            .IF hoverLevel > 3
                mov hoverLevel, 1
            .ENDIF

        .ELSEIF dx == VK_UP
            dec hoverLevel

            .IF hoverLevel < 1
                mov hoverLevel, 3
            .ENDIF

        .ELSEIF dx == VK_RETURN
            jmp goToGame

        .ENDIF

        call printMenuText
        call getMaxXy

        call gotoxy

    loop lookForKey

    goToGame:

    ret
openMenu ENDP


;-------------------------------------------
; Name: printMenuText
; purpose: purpose that check hoverLevel and print different difficulty 
;          such as easy/medium/hard with green color
; args: hoverLevel
; affect: NONE
; return: NONE
;-------------------------------------------
printMenuText PROC uses edx eax

    ;navigate message
    mGotoxy 27, 10
    mWrite "Select one of the following game modes using arrow keys"

    .IF hoverLevel == 1                 
        call setGreen
    .ENDIF
    mGotoxy 53, 13
    mWrite "EASY"
    call ResetColors

    .IF hoverLevel == 2                 
        call setGreen
    .ENDIF
    mGotoxy 53, 15
    mWrite "MEDIUM"
    call ResetColors

    .IF hoverLevel == 3                  
        call setGreen
    .ENDIF
    mGotoxy 53, 17
    mWrite "HARD"
    call ResetColors
    ret
printMenuText ENDP

;-------------------------------------------
; Name: loadingScreen
; purpose: print count down for the user to PREPARE
; args:   NONE
; affect: NONE
; return: NONE
;-------------------------------------------

loadingScreen PROC uses edx eax ecx
    
    mGotoxy 48,12
    mWrite "GAME ABOUT TO START IN"

    mov ecx, 3                      ;add dots
    dots:
        mDelay 100
        mWrite "."
    loop dots
    call clrscr

    mGotoxy 58, 12
    mWrite "3"
    mDelay 500
    call clrscr

    mGotoxy 58, 12
    mWrite "2"
    mDelay 500
    call clrscr

    mGotoxy 58, 12
    mWrite "1"
    mDelay 500
    call clrscr

    mGotoxy 58, 12
    mWrite "go"
    mDelay 500
    call clrscr

    ret
loadingScreen ENDP

;----------------------------------------------------------------
; Name:    setGreen
; purpose: set eax to color green
; args:    eax
; affect: NONE
; return: NONE
;----------------------------------------------------------------
setGreen PROC USES eax
    mov  eax,green+(black*16)
    call SetTextColor
    ret
setGreen ENDP


;----------------------------------------------------------------
; Name: setRed
; purpose: set eax to color red
; args:    eax
; affect: NONE
; return: NONE
;----------------------------------------------------------------
setRed PROC USES eax
    mov  eax,red+(black*16)
    call SetTextColor
    ret
setRed ENDP

;----------------------------------------------------------------
; Name: resetColors
; purpose: set eax to color white, a.k.a reset colors
; args:    eax
; affect: NONE
; return: NONE
;----------------------------------------------------------------
resetColors PROC USES eax
;reset text color
    mov  eax,white+(black*16)
    call SetTextColor

    ret
resetColors ENDP

;----------------------------------------------------------------
; Name: writePrompt
; purpose: Copy paragraph (OFFSET buffer) to paragraphBank for typing game based on difficulty level
; args:    USES edx esi edi eax hoverLevel
; affect:  Modifies fileHandle, paragraphSize, paragraphBank
; return:  NONE
;----------------------------------------------------------------
writePrompt PROC USES edx esi edi eax
    easy:
        cmp hoverLevel, 1
        jne medium
        mov edx, OFFSET easy_mode
        jmp difficulty_selected

    medium:
        cmp hoverLevel, 2
        jne hard
        mov edx, OFFSET medium_mode
        jmp difficulty_selected

    hard:
        mov edx, OFFSET hard_mode

    difficulty_selected:

        call OpenInputFile
        mov fileHandle, eax            

        mov edx, OFFSET buffer
        mov ecx, bufsize
        call ReadFromFile
        jc fileReadError

        mov edi, OFFSET buffer
        mov esi, OFFSET paragraphBank
        loop_word_to_bank:
            mov al, byte PTR [edi]
            cmp al, 0
            je DONE
            mov [esi], al
            inc esi
            inc edi
            inc paragraphSize

            jmp loop_word_to_bank

        fileReadError:
            mWrite "Could not read file"
            exit

        DONE:
            mov eax, fileHandle
            call CloseFile

            mWriteString OFFSET paragraphBank
    ret
writePrompt ENDP

;----------------------------------------------------------------
; Name: locateCursor
; purpose: Move the cursor to the specified (curX, curY) position on the screen
; args:    NONE
; affect:  Modifies dl, dh
; return:  NONE
;----------------------------------------------------------------
locateCursor PROC
    mov dl, curX
    mov dh, curY
    call gotoxy
    ret
locateCursor ENDP
;----------------------------------------------------------------
; Name: printStatistics
; purpose: Display the statistics at the bottom line of the typing tutor game
; args:    USES edx
; affect:  NONE
; return:  NONE
;----------------------------------------------------------------
printStatistics PROC USES edx eax
    call drawFinishLine
    call printTimer

    mWriteString OFFSET msgWordsTyped
    mWriteDec wordsTyped

    call locateCursor
    ret
printStatistics ENDP

;----------------------------------------------------------------
; Name: printTimer
; purpose: Display the elapsed time in minutes and seconds
; args:    minutes, seconds
; affect:  NONE
; return:  NONE
;----------------------------------------------------------------
printTimer PROC USES edx eax
    call convert_Timer_To_Minutes

    mWrite "Remaining Time: "

    mWriteDec minutes
    mWriteString OFFSET msgMinutes

    mWriteDec seconds
    mWriteString OFFSET msgSeconds

    call Crlf
    ret
printTimer ENDP

;----------------------------------------------------------------
; Name: dealBSpace
; purpose: Handle backspace functionality, adjusting cursor position and character display
; args:    None
; affect:  Modifies curX, curY, backtrack_Pilcrow, entered_bSpace
; return:  NONE
;----------------------------------------------------------------
dealBSpace PROC USES edx eax

    ;case (1): 
    .IF curX == 0 && curY == 0
        jmp DONE

    .ELSEIF curX == 0 && curY >= 0 && backtrack_Pilcrow <= 0
        call getMaxXY
        mov curX, dl
        dec curY
        jmp keep_going
    .ENDIF

    ;case(2):  backspace after the paragraph sign
    .IF backtrack_Pilcrow >= 1 && WORD PTR [esi - 4] == 0B6C2h 
        mov backtrack_Pilcrow, 0

        call resetColors        
        sub esi, 4
        mov dl, prevX
        mov dh, prevY

        mov curX, dl
        mov curY, dh
        call locateCursor

        mov al, BYTE PTR [esi]
        call WriteChar
        mov al, BYTE PTR [esi+1]
        call WriteChar
        jmp DONE
    .ENDIF

    ;case(3). backspace after a space
    .IF byte PTR [esi-1] == 20h
        mov entered_bSpace, 1
    .ELSE
        mov entered_bSpace, 0
    .ENDIF


	;case(4)  regular backspace
        dec esi
        dec curX

    keep_going:
        mov al, BYTE PTR [esi]
        call resetColors
        call locateCursor
        call WriteChar
    DONE:
        ret
dealBSpace ENDP

;----------------------------------------------------------------
; Name: deal_Word_Typed
; purpose: Update word count when a space character is typed
; args:    esi
; affect:  Modifies entered_bSpace, wordsTyped
; return:  NONE
;----------------------------------------------------------------
deal_Word_Typed PROC USES eax
    .IF entered_bSpace == 0 && byte ptr [esi] == 20h 
        mov entered_bSpace, 0 
        inc wordsTyped
    .ENDIF
        mov entered_bSpace,0
    ret
deal_Word_Typed ENDP

;----------------------------------------------------------------
; Name: dealWithInput
; purpose: Handle user input, including special cases for backspace, Enter, and pilcrow character
; args:    esi
; affect:  Modifies is_typing, Pilcrow_encounter
; return:  eax
;----------------------------------------------------------------
dealWithInput PROC USES edx

    mov ax, word PTR [esi]
    .IF WORD PTR [esi] == 0B6C2h            ;IF(1) first check if next word is pilcrow character
        mDelay 10
        call ReadKey
        jz Special_case_no_Read
        mov is_typing, 1                    ;user is typing 

        .IF al == 8                         ;user enter a space
            jmp DONE
        .ELSEIF al == VK_RETURN
            mov Pilcrow_encounter, 1        ;user press "Enter" to next paragraph
            jmp DONE
        .ELSE
            mov Pilcrow_encounter, 2        ;user didn't press "Enter" to go next paragraph
            jmp DONE
        .ENDIF    

    .ELSE                                   ;else(1) normal read letter 
        ReadLetter:
            mDelay 10
            call ReadKey
            jz no_Read
            mov is_typing, 1                ;user is typing
            jmp DONE
    .ENDIF

    Special_case_no_Read:                   ;under speical case
        mov is_typing, 0
        mov Pilcrow_encounter, 3            ;user didn't press at all
        jmp DONE

    no_Read:
        mov is_typing, 0                    ;user not typing
        mov Pilcrow_encounter, 0
        jmp DONE

    DONE:
        ret
dealWithInput ENDP

;----------------------------------------------------------------
; Name: runTest
; purpose: Main game loop to handle user input, and manage game state
; args:    Pilcrow_encounter, is_typing
; affect:  Modifies curX, curY, prevX, prevY, totalInputCount, mistakes, backtrack_Pilcrow
; return:  NONE
;----------------------------------------------------------------
runTest PROC USES eax
  
    Game_Loop: 
        call printStatistics

        call dealWithInput
        .IF al == 8                           ;if it is a backspace
            call dealBSpace
            jmp DONE
        .ELSEIF al == 32                      ;if it is a space
            call deal_Word_Typed
        .ELSEIF al == VK_ESCAPE
            call clrscr
            mWrite "Returning to main menu"
            mDelay 2000
            mov return_main_menu, 1
            ret
        .ENDIF

        .IF Pilcrow_encounter == 1            ;it is solved
            jmp CHAR_MATCH
        .ELSEIF Pilcrow_encounter == 2        ;it is not solved
            jmp CHAR_MISMATCH
        .ELSEIF Pilcrow_encounter == 3 || is_typing == 0
            jmp DONE
        .ELSE
            inc totalInputCount
            cmp BYTE PTR [esi], al            ;compare the characters
            jne CHAR_MISMATCH
            jmp CHAR_MATCH            
        .ENDIF



        CHAR_MISMATCH:                          ;input doesnt match 
            call setRed
            inc mistakes
            .IF Pilcrow_encounter == 2          ;user is facing a pilcrow sign and enter wrong key
                mov al, 0C2h
                call WriteChar
                mov al, 0B6h
                call WriteChar
                jmp DONE
            .ELSE                               ;user isn't facing a pilcrow sign and enter wrong key
                jmp keep_going
            .ENDIF


        CHAR_MATCH:                             ;input does match 
            call setGreen
            .IF Pilcrow_encounter == 1
                mov al, 0C2h
                call WriteChar
                mov al, 0B6h
                call WriteChar
                call Crlf
                call Crlf
                add esi, 4
                mov Pilcrow_encounter, 0
                add backtrack_Pilcrow, 1
                jmp go_next_para  
            .ELSEIF Pilcrow_encounter == 0      ;user isn't facing a pilcrow sign and enter right key
                jmp keep_going
            .ENDIF

        keep_going:

            mov al, BYTE PTR [esi]
            call WriteChar
            inc curX                           ;keep track on the current X 
            inc esi                            ;move the next character
	        call getMaxXY 	                   ;check if we are at next line
            dec dl
	        cmp dl, curX
	        jae DONE

        go_next_line:                          ;inc curY if we're going next line
            add curY,1
            mov curX,0
            jmp DONE

        go_next_para:                          ;inc curY if we're going next paragraph
            mov dl, curX
            mov dh, curY
            mov prevX, dl
            mov prevY, dh

	        add curY, 2
	        mov curX, 0
            jmp DONE

        DONE: 
            call locateCursor
            call resetColors
    ret
runTest ENDP

;----------------------------------------------------------------
; Name: typingTutorGame
; purpose: Main function to run the typing tutor game, initialize cursor, handle game logic, and check end conditions
; args:    NONE
; affect:  Modifies esi, ecx, cursorInfo, Timer
; return:  NONE
;----------------------------------------------------------------
typingTutorGame PROC USES esi ecx
    ; TODO
    mov cursorInfo.dwSize, 1
    mov cursorInfo.bVisible, 1
    invoke SetConsoleCursorInfo, hConsoleOutput, ADDR cursorInfo   ;show cursor

    call writePrompt
    mGotoxy 0, 0
    mov esi, OFFSET paragraphBank

    call getMseconds
    mov startTime, eax

    game_logic:
        call runTest 

    call GetMseconds 
    .IF eax >= startTime
        sub Timer, 1000
        add startTime, 1000
   .ENDIF

     .IF return_main_menu == 1
        ret
     .ELSEIF byte PTR [esi] == 0 || Timer == 0
        jmp Finish
     .ELSE
        jmp game_logic
     .ENDIF


    Finish:
        call resetColors
        ret
typingTutorGame ENDP


;----------------------------------------------------------------
; Name: GetWordsFromFile
; purpose: Read words from a file into a word bank based on the selected difficulty level
; args:    hoverLevel
; affect:  Modifies eax, esi, edi, ecx, edx, fileHandle, bytesWritten, totalWords
; return:  NONE
;----------------------------------------------------------------
GetWordsFromFile PROC uses eax esi edi ecx edx
    easy:
        cmp hoverLevel, 1
        jne medium
        mov edx, OFFSET dict_4
        jmp difficulty_selected

    medium:
        cmp hoverLevel, 2
        jne hard
        mov edx, OFFSET dict_8
        jmp difficulty_selected

    hard:
        mov edx, OFFSET dict_12

    difficulty_selected:

        call OpenInputFile
        mov fileHandle, eax            

        mov edx, OFFSET buffer
        mov ecx, bufsize
        call ReadFromFile
        jc fileReadError
        mov bytesWritten, eax

        mov esi, offset buffer
        mov edi, offset wordBank

        tokenize_loop:

            mov al, [esi]
            .IF al == 0
                jmp tokenize_done

            .ELSEIF al == ' '
                mov byte PTR [edi], 0
                inc totalWords
                jmp done

            .ELSE
                mov [edi], al
                jmp done

            .ENDIF

        done:
            inc edi
            inc esi
            jmp tokenize_loop

    tokenize_done:

        inc totalWords
        jmp close_file

    fileReadError:
        mWrite "Could read da File"

    close_file: 
        mov eax, fileHandle
        call CloseFile
    ret
GetWordsFromFile ENDP

;----------------------------------------------------------------
; Name: generateRandXY
; purpose: Generate random X coordinates for words based on the length of each word and screen dimensions
; args:    NONE
; affect:  Modifies arrXCords
; return:  NONE
;----------------------------------------------------------------
generateRandXY PROC uses ecx esi edx eax
    
    mov esi, OFFSET arrXCords
    mov ecx, totalWords
    mov edx, OFFSET wordBank

    call randomize

    generate:  ;for x coordinates
        push edx
        call StrLength
        mov StringLength, eax
        call getMaxXY
       
        sub edx, StringLength         
        movzx eax, dl 
        call randomRange
        mov [esi], al
        inc esi

        pop edx
        add edx, StringLength
        inc edx

    loop generate 

    ret
generateRandXY ENDP



;----------------------------------------------------------------
; Name: drawFinishLine
; purpose: Draw the finish line on the console and display the number of mistakes made
; args:    NONE
; affect:  NONE
; return:  NONE
;----------------------------------------------------------------
drawFinishLine PROC USES edx eax ecx

    mGotoxy 0,lineHeight            

    mWriteString OFFSET finishLine  ;print "finishLine"

    call crlf                      
    mWrite "Mistakes: "             ;print "Mistake"
    mWriteDec mistakes

    call crlf
    call resetColors

    ret
drawFinishLine ENDP

;----------------------------------------------------------------
; Name: CheckTouchLine
; purpose: Check if the line is touched and update game status accordingly
; args:    NONE
; affect:  Modifies ecx, isLost
; return:  NONE
;----------------------------------------------------------------
CheckTouchLine PROC 
    cmp isTouchLine, 1
    jne continue
    mov ecx, 1
    mov isLost, 1

    continue:
    ret
CheckTouchLine ENDP

;----------------------------------------------------------------
; Name: check_should_Printed
; purpose: Check if the current word should be printed, compare input and output arrays, and update game statistics accordingly
; args:    NONE
; affect:  Modifies charsTyped, wordsTyped, should_Printed
; return:  NONE
;----------------------------------------------------------------
check_should_Printed PROC USES esi edx ecx eax
    cmp currentWordLength,0             ;if = 0, which means no words are being type
    je DONE
    mov eax, currentWordLength
    .IF charsTyped == eax               ;this function only excuate when charsTyped == currentWordLength
        call findCurrentPosition

    Start:
    mov esi, OFFSET inputArr
    mov edx, OFFSET outputArr

    INVOKE Str_compare, esi, edx   

    je equal
    ja larger
    jmp DONE

    equal:
        movzx ebx, currentWord

        mov ecx, LENGTHOF inputArr
        clear_input:                    ;clear_input
            mov BYTE PTR [esi], 0
            inc esi
        loop clear_input

        mov ecx, LENGTHOF outputArr    ;clear output just incase of bug
        clear_output:
            mov BYTE PTR [edx],0
            inc edx
        loop clear_output

        inc wordsTyped                ;inc one to wordsTyped
        mov should_Printed[ebx] , 0   ;this word won't be process anymore
        mov charsTyped, 0 
        jmp DONE

    larger:
        jmp equal                     ;just incase of bug 
    DONE:
    .ENDIF
        ret
check_should_Printed ENDP

;----------------------------------------------------------------
; Name: PrintWords
; purpose: Print words from the word bank based on their printing status and coordinates
; args:    NONE
; affect:  Modifies isTouchLine
; return:  NONE
;----------------------------------------------------------------
PrintWords PROC USES edx ecx esi eax ebx
    mov esi, OFFSET wordBank
    mov ecx, wordsPrinted
    mov ebx, 0
    check_print_word:
        .IF should_Printed[ebx] == 1    ;check if current words need to print out
            jmp should_print
        .ELSEIF should_Printed[ebx] == 0
            mov edx, esi
            jmp keep_looping
        .ENDIF

        should_print:
            mov dl, arrXcords[ebx]
            mov dh, arrYcords[ebx]
            call gotoxy

            cmp dh, lineHeight          ;check if current words has touched the base line
            jne print_word
            mov isTouchLine, 1

            print_word:
                mov edx, esi
                call WriteString
                jmp keep_looping

        keep_looping:
            call StrLength
            inc eax
            add esi, eax
            inc ebx
            loop check_print_word
            mov currentWord, 0
    ret
PrintWords ENDP

;----------------------------------------------------------------
; Name: findCurrentPosition
; purpose: Find the current position of the inputArr in the wordBank and update currentWord accordingly
; args:    NONE
; affect:  Modifies currentWord
; return:  NONE
;----------------------------------------------------------------
findCurrentPosition PROC USES ecx ebx eax
    mov edx, OFFSET wordBank           ; Start of wordBank
    mov al, inputArr[0]                ; we just need to check the first word to know where current position at
    mov ecx, wordsPrinted
    mov ebx, 0
    L1:
        push eax
        call StrLength
        mov StringLength, eax
        inc StringLength
        pop eax
        .IF should_printed[ebx] == 0  ; skip if the words are already gone
             inc currentWord
             add edx, StringLength
             inc ebx
        .ELSEIF al == BYTE PTR [edx] 
            ret
        .ELSEIF al != BYTE PTR [edx]
            inc currentWord
            add edx, StringLength
            inc ebx
        .ENDIF

    loop L1
    ret
findCurrentPosition ENDP

;----------------------------------------------------------------
; Name: PrintInputArr
; purpose: Print the inputArr with green/red colors
; args:    NONE
; affect:  Modifies the color of the current word
; return:  NONE
;----------------------------------------------------------------

PrintInputArr PROC USES edx ecx esi eax ebx
    .IF charsTyped >= 1
        call findCurrentPosition
    .ENDIF 

    movzx ebx, currentWord
    mgotoxy arrXcords[ebx],arrYcords[ebx]

    mov ecx, charsTyped
    mov esi, OFFSET inputArr  
    mov edi, OFFSET inputColor
    .IF error_count == 0
        jmp keep_going
    .ELSE
        .IF charsTyped == 1
            jmp DONE
        .ELSEIF charsTyped >= 2
            jmp keep_going
        .ENDIF
    .ENDIF  
        
        keep_going:
        .IF charsTyped > 0                        ;if user didn't type at all, skip loop
        LOOP_CHAR:                                ;print words with color
                .IF byte PTR[edi] == 0            ;if input is false, set Red
                    call setRed
                .ELSEIF byte PTR [edi] == 1       ;if input is true, set Green
                    call setGreen
                .ENDIF

                mov al, BYTE PTR [esi]
                call WriteChar
                inc esi
                inc edi
        loop LOOP_CHAR
        .ENDIF
    DONE:
        call resetColors
        mov currentWord, 0
    ret
PrintInputArr ENDP

;----------------------------------------------------------------
; Name: checkInput
; purpose: Check user input against words from the wordBank
; args:    NONE
; affect:  Carry flag
; return:  Sets the carry flag (CF) to indicate whether a match is found or not
;----------------------------------------------------------------
checkInput PROC USES esi edi ecx edx eax ebx
    mov edx, OFFSET wordBank           ; Start of wordBank
    mov ecx, wordsPrinted              ; Number of words printed
    mov edi, OFFSET inputArr           ; User input array
    mov esi, OFFSET outputArr          ; Word from wordBank

    mov ebx, 0                         ; Index for should_printed array

    word_check_loop:

        cmp ecx, 0                    ; If no more words to check, exit loop
        je check_done

        cmp should_printed[ebx], 0
        je next_word
        

        ; Copy the word from wordBank to outputArr
        INVOKE str_Copy, edx, esi


        ; Compare the user's input with the current word
        mov esi, OFFSET outputArr      ; Word from wordBank
        mov edi, OFFSET inputArr       ; inputArr 
        push ecx
        mov ecx, charsTyped            ; Length of the strings to compare
        call compareStrings
        pop ecx
        jnc match_found                ; If strings match, found the word

        next_word:
            call StrLength
            add edx, eax

            inc edx                   ; Move past the null terminator
            inc ebx
            dec ecx
            jmp word_check_loop

    match_found:
        clc                           ; Clear carry flag to indicate match
        ret

    check_done:
        stc                           ; Set carry flag to indicate no match
        ret

checkInput ENDP

;----------------------------------------------------------------
; Name: compareStrings
; purpose: Compare two strings
; args:    esi edi ecx 
; affect:  Carry flag
; return:  Sets the carry flag (CF) to indicate whether the strings are equal or not
;----------------------------------------------------------------
compareStrings PROC USES ecx eax esi edi edx

    repe cmpsb                        ; Compare strings byte by byte
    je strings_equal                  ; If strings are equal, jump
    stc                               ; Set carry flag to indicate strings are not equal
    ret

strings_equal:
    mov edx, OFFSET outputArr
    call strLength
    mov currentWordLength, eax
    clc                               ; Clear carry flag to indicate strings are equal
    ret
compareStrings ENDP

;----------------------------------------------------------------
; Name: CheckKey
; purpose: Process the key pressed by the user and update game statistics
; args:    NONE
; affect:  Modifies charsTyped, inputArr, error_count, mistakes, totalInputCount, isWon
; return:  NONE
;----------------------------------------------------------------
CheckKey PROC USES edx esi eax ecx edi
    mDelay 10
    call ReadKey
    jz DONE
    mov ebx, currentWordLength

    .IF ebx == 0
        inc ebx
    .ENDIF

    .IF (al >=  0 && al <= 32) || ebx < charsTyped
        jmp DONE
    .ENDIF

    inc totalInputCount             ;this for statistic of the game

    .IF error_count == 0
        inc charsTyped
    .ENDIF

     mov edi, OFFSET inputArr
     add edi, charsTyped
     dec edi
     mov BYTE PTR [edi], al

    call checkInput
    JC CHAR_MISMATCH
    jmp CHAR_MATCH

    CHAR_MISMATCH: 
        .IF error_count == 0
            mov edi, OFFSET inputColor
            add edi, charsTyped
            dec edi
            mov byte PTR [edi], 0

            inc error_count
            inc mistakes
            jmp DONE
        .ELSEIF error_count == 1
            inc mistakes            ;this for statistic of the game
            jmp DONE
        .ENDIF

    CHAR_MATCH:
        .IF error_count == 1
            dec error_count
            JMP keep_on
        .ELSEIF error_count == 0
            JMP keep_on
        .ENDIF

        keep_on:
            mov edi, OFFSET inputColor 
            add edi, charsTyped
            dec edi
            mov byte PTR [edi], 1

    DONE:  
        call PrintInputArr        

        mov eax, totalWords              ; check if you typed all the words, b4 touch the line
        .IF wordsTyped == eax
            mov isWon, 1
        .ENDIF
    ret
CheckKey ENDP

;----------------------------------------------------------------
; Name: increase_y
; purpose: Increase the y-coordinate of words that are printed in the game
; args:    NONE
; affect:  Modifies arrYcords
; return:  NONE
;----------------------------------------------------------------
increase_y PROC USES ecx ebx
    mov ecx, wordsPrinted
    mov ebx, 0

    increase:
        .IF should_printed[ebx] == 0
            inc ebx
        .ELSEIF should_printed[ebx] == 1
            inc arrYcords[ebx]
            inc ebx
        .ENDIF
    loop increase
    ret
increase_y ENDP
    
;----------------------------------------------------------------
; Name: FallingWordGame
; purpose: main purpose of falling word game, combine all the falling word game function that are built for it.
; args:    NONE
; affect:  NONE
; return:  NONE
;----------------------------------------------------------------
FallingWordGame PROC USES edx ebx eax esi

    set_up:
        call getWordsFromFile
        call generateRandXY             ;fill up cords
        call GetMseconds                ;get initial time before program starts

        mov startTime, eax
        mov msec, eax                   ;time interval for dropping words by one line

    Game_Loop:

        mov ecx, totalWords

        mgotoxy 0,0


        call CheckKey
        call check_should_Printed

        call GetMseconds 
        ;only jump line if 1 sec has passed
        .IF eax >= msec
       
            call clrscr

            call increase_y
            call drawFinishLine                 ;draw FinishLine

            call printWords                     ;print all the words in the array

            mov eax, totalWords
            .IF wordsPrinted < eax
                inc wordsPrinted
            .ENDIF
            add msec, 1000
        .ENDIF  
   

    call CheckTouchLine                     ;check finish
    .IF isWon == 1 || isLost == 1
        jmp DONE
    .ELSEIF isWon == 0
        jmp Game_Loop
    .ENDIF

    DONE:
        call GetMSeconds
        mov endTime,eax
        ret
FallingWordGame ENDP

;----------------------------------------------------------------
; Name: finishMsg
; purpose: Display the appropriate finish message based on game outcome
; args:    NONE
; affect:  NONE
; return:  NONE
;----------------------------------------------------------------
finishMsg PROC
    
    call clrscr
    mgotoxy 40, 10
    .IF switchGame == 1
        mWriteString OFFSET msgResult
    .ELSEIF switchGame == 2

        .IF isLost == 1
            mWriteString  OFFSET msgLost
        .ELSEIF isWon == 1
            mWriteString  OFFSET msgWon
        .ENDIF

    .ENDIF
    ret
finishMsg ENDP

;----------------------------------------------------------------
; Name: gameReport
; purpose: Display the game report including mistakes, WPM, accuracy, time taken, and score
; args:    NONE
; affect:  NONE 
; return:  NONE
;----------------------------------------------------------------
gameReport PROC uses EDX EAX
        
        call calc_everything

        .IF switchGame == 1

            ;Print_Mistake:
                mgotoxy 50, 12                  ;Mistake
                mWrite "Mistakes: "
                mWriteDec mistakes

                call crlf

            ;Print_WPM:
                mgotoxy 50, 13                  ;WPM
                mWrite "WPM: "
                mWriteDec WPM

            ;Print_Accuracy:     
                mgotoxy 50, 14                  ;Accuracy
                mWrite "Accuracy: "
                mWriteDec accuracy


        .ELSEIF switchGame == 2

            ;Print_Time_used:                    ;time_used
                mgotoxy 50,11
                mWrite "Time taken :"

                mWriteDec minutes
                mWriteString OFFSET msgMinutes

                mWriteDec seconds
                mWriteString OFFSET msgSeconds

                call Crlf

            ;Print_Mistake:
                        
                mgotoxy 50, 12                  ;Mistake
                mWrite "Mistakes: "
                mWriteDec mistakes
                call crlf

            ;Print_Accuracy:
                mgotoxy 50,13                   ;Accuracy
                mWrite "Accuracy: "
                mWriteDec accuracy


            ;Print_Score:
                mgotoxy 50,14                    ;Score
                mWriteString OFFSET msgScore
                mWriteDec score

         .ENDIF
    ret
gameReport ENDP

;----------------------------------------------------------------
; Name: calc_everything
; purpose: Calculate game statistics including WPM, time used, score, and accuracy based on the game type
; args:    NONE
; affect:  Modifies switchGame, WPM, minutes, seconds, score, accuracy
; return:  NONE
;----------------------------------------------------------------
calc_everything proc
    .IF switchGame == 1
        call calc_WPM
    .ELSEIF switchGame == 2
        call calc_Time_used
    .ENDIF

     call calc_score
     call calc_Accuracy
    ret
calc_everything ENDP

;----------------------------------------------------------------
; Name: calc_WPM
; purpose: Calculate the Words Per Minute (WPM) based on the number of words typed and total input count
; args:    NONE
; affect:  Modifies WPM
; return:  NONE
;----------------------------------------------------------------
calc_WPM PROC USES eax 
    .If totalInputCount < 0
        mov WPM, 0
    .ELSE
        mov eax, wordsTyped
        mov WPM, eax
    .ENDIF

    ret
calc_WPM ENDP

;----------------------------------------------------------------
; Name: calc_Accuracy
; purpose: Calculate the accuracy of the typing based on the total input count and mistakes
; args:    NONE
; affect:  Modifies ACCURACY
; return:  NONE
;----------------------------------------------------------------
calc_Accuracy PROC
    .IF totalInputCount > 0
        xor edx, edx
        mov eax, totalInputCount
        mov ebx, mistakes
        sub eax, ebx
        mov ebx, 100
        mul ebx
        mov ebx, totalInputCount
        div ebx
        mov ACCURACY, eax
    .ELSE
        mov ACCURACY, 0
    .ENDIF
    ret
calc_Accuracy ENDP

;----------------------------------------------------------------
; Name: calc_Time_used
; purpose: Calculate the time used for the typing test based on start and end time
; args:    NONE
; affect:  Modifies elapsedTime, minutes, seconds
; return:  NONE
;----------------------------------------------------------------
calc_Time_used PROC USES eax ecx edx
    mov eax, endTime
    sub eax, startTime
    mov elapsedTime, eax

    mov ecx, 60000
    xor edx, edx
    div ecx
    mov minutes, eax
    mov eax, edx
    mov ecx, 1000
    xor edx, edx
    div ecx
    mov seconds, eax
    ret
calc_Time_used ENDP

;----------------------------------------------------------------
; Name: convert_Timer_To_Minutes
; purpose: Convert the timer value to minutes and seconds
; args:    NONE
; affect:  Modifies minutes, seconds
; return:  NONE
;----------------------------------------------------------------
convert_Timer_To_Minutes PROC USES eax ecx edx
    mov eax, Timer

    mov ecx, 60000
    xor edx, edx
    div ecx
    mov minutes, eax
    mov eax, edx
    mov ecx, 1000
    xor edx, edx
    div ecx
    mov seconds, eax
    ret
convert_Timer_To_Minutes ENDP

;----------------------------------------------------------------
; Name: calc_score
; purpose:  Calculate the score based on words typed and mistakes
;           (wordsTyped * 100) - (mistake * 50) = score
; args:    NONE
; affect:  Modifies score
; return:  NONE
;----------------------------------------------------------------
calc_score PROC USES eax ebx
    mov eax, wordsTyped
    mov ebx, 100
    mul ebx
    mov score, eax
    mov eax, mistakes
    mov ebx, 50
    mul ebx
    sub score, eax
    ret
calc_score ENDP


;----------------------------------------------------------------
; Name: ask_for_save
; purpose: Prompt the user for their name and whether they want to save the game
; args:    NONE
; affect:  Modifies String_Name, isSave
; return:  NONE
;----------------------------------------------------------------
ask_for_save PROC USES edx eax
    prompt_user:
        mWrite "Enter your name :"
        mReadString String_Name
        mov stringLength, eax
        
        call crlf
        mWrite "Do you want to save (Yes 1/ No 0): "
        call ReadDec
        mov isSave, al


        .IF isSave == 1
            call saving
            jmp DONE
        .ELSEIF isSave == 0
            mWrite "See you next time! "
            ret
        .ELSE
            mWrite "Please enter a correct key! Try again! "
            mDelay 2000
            jmp prompt_user
        .ENDIF
    DONE:
        call crlf
        mWrite "Saving"
        mDelay 1000
        mWrite "."
        mDelay 1000
        mWrite "."
        mDelay 1000
        mWrite "."
        mDelay 1000
        call clrscr
        mWrite "Saved, See you next time "
        mWriteString OFFSET String_Name
        mWrite "!"
        ret
 ask_for_save ENDP

;----------------------------------------------------------------
; Name: saving
; purpose: Save the game result to a file
; args:    NONE
; affect:  Modifies resultCombined, outputFile
; return:  NONE
;----------------------------------------------------------------
saving PROC
    lea esi, [score]
    lea edi, [str_score]
    call int_to_string

    mov edi, OFFSET newLine
    mov esi, OFFSET resultCombined
    INVOKE Str_copy, edi, esi

    mov edi, OFFSET String_Name
    add esi, LENGTHOF newLine -1
    INVOKE Str_copy, edi, esi
    
    add esi, StringLength
    mov byte PTR [esi], 20h

    mov edi, OFFSET msgScore
    inc esi
    INVOKE Str_copy, edi, esi

    mov edi, OFFSET str_score
    add esi, LENGTHOF msgScore-1
    INVOKE Str_copy, edi, esi

    add esi, LENGTHOF str_score-1
    mov byte PTR [esi], 2Eh

    open_file:
        mov edx, OFFSET outputFile
        INVOKE CreateFile, edx, GENERIC_WRITE,0,0,OPEN_EXISTING,FILE_ATTRIBUTE_NORMAL,0
        mov fileHandle, eax

    check_File:
        cmp fileHandle, INVALID_HANDLE_VALUE
        je file_error

    write_File:
        call WriteResultToFile
        jmp close_File

    file_error:
        mWrite <"Error opening file", 0Dh, 0Ah>
        call Crlf
        jmp Done

    close_File:
        mov eax, fileHandle
        INVOKE CloseHandle, eax

    Done:
        ret
saving ENDP

;----------------------------------------------------------------
; Name: WriteResultToFile
; Purpose: Appends the content stored in resultCombined to a file
; Args:    fileHandle - Handle to the file
;          resultCombined - Pointer to the string containing the content to be written
; Affects: NONE
; Returns: NONE
;----------------------------------------------------------------

WriteResultToFile PROC USES eax edx ecx
    INVOKE SetFilePointer, eax, 0, 0, FILE_END
    mov edx, OFFSET resultCombined 
    call StrLength
    mov ecx, fileHandle
    xchg eax, ecx
    INVOKE WriteFile, eax, edx, ecx, ADDR bytesWritten, 0
    ret
WriteResultToFile ENDP

;----------------------------------------------------------------
; Name: int_to_string
; Purpose: Converts an integer stored in [esi] into a string representation
;          and stores it in the buffer pointed to by edi.
; Args:    esi - Pointer to the integer to be converted
;          edi - Pointer to the buffer where the string will be stored
; Affects: edx, eax, ecx
; Returns: NONE
;----------------------------------------------------------------
int_to_string PROC USES eax edx ecx
    mov eax, [esi]    
    mov ecx, 10       ; divisor (base 10)
    lea edi, [edi+4]  
    mov byte PTR [edi], 0 

convert_loop:
    dec edi           ; move back one position in the buffer
    xor edx, edx      
    div ecx           ; divide eax by 10
    add dl, '0'       
    mov [edi], dl     ; store the character in the buffer
    test eax, eax     
    jnz convert_loop  
    ret
int_to_string ENDP

;----------------------------------------------------------------
; Name: show_Statistics
; Purpose: Reads statistics data from a file and displays it.
; Args:    NONE
; Affects: NONE
; Returns: NONE
;----------------------------------------------------------------
show_Statistics PROC USES edx ecx eax
     mov edx, OFFSET outputFile  
     call OpenInputFile
     mov fileHandle, eax

     mov edx, OFFSET buffer
     mov ecx, bufsize
     call ReadFromFile
     jc fileReadError
     jmp DONE


     fileReadError:
        mWrite "Could not read file"
        exit     

     DONE:
        mWriteString OFFSET buffer
        mov eax, fileHandle
        call closeFile
        ret
show_Statistics ENDP

;----------------------------------------------------------------
; Name: Reset
; Purpose: Reset every variables to make sure it works for next time
; Args:    NONE
; Affects: Modified Timer, curX, cuY, prevX/Y, maxX, is_typing, backtrack_Pilcrow etc...
; Returns: NONE
;----------------------------------------------------------------
Reset PROC USES ecx
    mov Timer, 60000
    mov curX, 0                                     
    mov curY, 0
    mov prevX, 0                
    mov prevY, 0                
    mov maxX, 0     
    mov is_typing, 0
    mov backtrack_Pilcrow, 0    
    mov Pilcrow_encounter, 0
    mov return_main_menu, 0
    mov wordsTyped, 0
    mov mistakes, 0
    mov ecx, bufSize
    L1:
        mov buffer[ecx],0
    loop L1

    ret
Reset ENDP
;----------------------------------------------------------------
; Name: testing
; Purpose: Provides options to select different game modes, displays corresponding games, and handles the end of the program.
; Args:    NONE
; Affects: NONE
; Returns: NONE
;----------------------------------------------------------------
testing PROC 

Start:
    mgotoxy 0, 29
    mWriteString OFFSET profile

    mgotoxy 0,0
    mWriteString OFFSET menu_prompt

    call ReadDec

    .IF al >= 4
        call Clrscr
        mWrite "Invalid input, Please Try Again! "
        mDelay 2000
        jmp Start
    .ENDIF

    mov switchGame, al

    .IF switchGame == 1
        call Clrscr
        call openMenu
        call Clrscr
        jmp MODE_1

    .ELSEIF switchGame == 2
        call Clrscr
        call openMenu
        call Clrscr
        jmp MODE_2

    .ELSEIF switchGame == 3 
        call Clrscr
        call show_Statistics
        call Crlf
        call WaitMsg
        call Reset
        call Clrscr
        jmp Start
    .ENDIF


    MODE_1: 
        call loadingScreen
        call typingTutorGame
        call clrscr 
        .IF return_main_menu == 1
            call reset
            jmp Start
        .ENDIF
        mgotoxy 58, 13
        mWrite "Time's up! "
        mDelay 2000

        jmp show_Result

    MODE_2:
        call loadingScreen
        call FallingWordGame
        call clrscr 
        mgotoxy 58, 13
        mWrite "Time's up! "
        mDelay 2000

        jmp show_Result

    show_Result:
        call finishMsg
        call crlf
        call gameReport
        call crlf
        call WaitMsg

    ask_save:
    .IF switchGame == 1
        mWrite "Thank you for playing, see you next time! "
        ret
    .ELSE
        call clrscr
        call ask_for_save    
    .ENDIF

    ENDPROGRAM:    
       
        ret
testing ENDP

;----------------------------------------------------------------
; Name: main
; purpose: call testing
; Args:    NONE
; Affects: NONE
; Returns: NONE 
;----------------------------------------------------------------
main PROC
    call testing
    exit
main ENDP

END main
