
# Work Report

## Name: <ins> Kin Yin Ho </ins>

## Features:
- Implemented:
  - typing game
  ![](https://github.com/barkeshli-CS066-classroom/99-final-project-typing-tutor-benho612/blob/master/MASMfinalP1.gif)
<br><be>
  - Falling word game
  ![](https://github.com/barkeshli-CS066-classroom/99-final-project-typing-tutor-benho612/blob/master/MASMfinalP2.gif)
<br><be>
  - Statistic
  ![](https://github.com/barkeshli-CS066-classroom/99-final-project-typing-tutor-benho612/blob/master/MASMfinalP3.gif)


<br><br>

# FULL PRESENTATION VIDEO:

https://drive.google.com/file/d/1De4NXfXLEvB0LoGZxpmmbJ1Stb6c7VHc/view?usp=sharing

# BUG
  - There may be a small chance users are stuck at the end of a word due to the refresh timing.

# FUTURE IMPROVEMENT
  - Instead of dropping words in a specific order, the program can drop them in a random order.
# LIST OF FUNCTIONS:

<pre>
;-------------------------------------------
; Name: mDelay
; purpose: call Delay
; args: delayTime
; affect: NONE
; return: NONE
;-------------------------------------------
</pre>
<br/><br/>

<pre>
;-------------------------------------------
; Name: mWriteDec
; purpose: call WriteDec 
; args: integer
; affect: NONE
; return: NONE
;-------------------------------------------
</pre>
<br/><br/>


<pre>
;-------------------------------------------
; Name: openMenu
; purpose: purpose used to print the select difficulty menu
; args: hoverLevel
; affect: NONE
; return: NONE
;-------------------------------------------
</pre>
<br/><br/>

<pre>
;-------------------------------------------
; Name: printMenuText
; purpose: purpose that check hoverLevel and print different difficulty 
;          such as easy/medium/hard with green color
; args: hoverLevel
; affect: NONE
; return: NONE
;-------------------------------------------
</pre>
<br/><br/>


<pre>
;-------------------------------------------
; Name: loadingScreen
; purpose: print count down for the user to PREPARE
; args:   NONE
; affect: NONE
; return: NONE
;-------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name:    setGreen
; purpose: set eax to color green
; args:    eax
; affect: NONE
; return: NONE
;----------------------------------------------------------------
</pre>
<br/><br/>


<pre>
;----------------------------------------------------------------
; Name: setRed
; purpose: set eax to color red
; args:    eax
; affect: NONE
; return: NONE
;----------------------------------------------------------------
</pre>
<br/><br/>


<pre>
;----------------------------------------------------------------
; Name: resetColors
; purpose: set eax to color white, a.k.a reset colors
; args:    eax
; affect: NONE
; return: NONE
;----------------------------------------------------------------
</pre>
<br/><br/>


<pre>
;----------------------------------------------------------------
; Name: writePrompt
; purpose: Copy paragraph (OFFSET buffer) to paragraphBank for typing game based on difficulty level
; args:    USES edx esi edi eax hoverLevel
; affect:  Modifies fileHandle, paragraphSize, paragraphBank
; return:  NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: locateCursor
; purpose: Move the cursor to the specified (curX, curY) position on the screen
; args:    NONE
; affect:  Modifies dl, dh
; return:  NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: printStatistics
; purpose: Display the statistics at the bottom line of the typing tutor game
; args:    USES edx
; affect:  NONE
; return:  NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: printTimer
; purpose: Display the elapsed time in minutes and seconds
; args:    minutes, seconds
; affect:  NONE
; return:  NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: dealBSpace
; purpose: Handle backspace functionality, adjusting cursor position and character display
; args:    None
; affect:  Modifies curX, curY, backtrack_Pilcrow, entered_bSpace
; return:  NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: deal_Word_Typed
; purpose: Update word count when a space character is typed
; args:    esi
; affect:  Modifies entered_bSpace, wordsTyped
; return:  NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: dealWithInput
; purpose: Handle user input, including special cases for backspace, Enter, and Pilcrow character
; args:    esi
; affect:  Modifies is_typing, Pilcrow_encounter
; return:  eax
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: runTest
; purpose: Main game loop to handle user input, and manage game state
; args:    Pilcrow_encounter, is_typing
; affect:  Modifies curX, curY, prevX, prevY, totalInputCount, mistakes, backtrack_Pilcrow
; return:  NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: typingTutorGame
; purpose: Main function to run the typing tutor game, initialize cursor, handle game logic, and check end conditions
; args:    NONE
; affect:  Modifies esi, ecx, cursorInfo, Timer
; return:  NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: GetWordsFromFile
; purpose: Read words from a file into a word bank based on the selected difficulty level
; args:    hoverLevel
; affect:  Modifies eax, esi, edi, ecx, edx, fileHandle, bytesWritten, totalWords
; return:  NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: generateRandXY
; purpose: Generate random X coordinates for words based on the length of each word and screen dimensions
; args:    NONE
; affect:  Modifies arrXCords
; return:  NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: drawFinishLine
; purpose: Draw the finish line on the console and display the number of mistakes made
; args:    NONE
; affect:  NONE
; return:  NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: CheckTouchLine
; purpose: Check if the line is touched and update game status accordingly
; args:    NONE
; affect:  Modifies ecx, isLost
; return:  NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: check_should_Printed
; purpose: Check if the current word should be printed, compare input and output arrays, and update game statistics accordingly
; args:    NONE
; affect:  Modifies charsTyped, wordsTyped, should_Printed
; return:  NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: PrintWords
; purpose: Print words from the word bank based on their printing status and coordinates
; args:    NONE
; affect:  Modifies isTouchLine
; return:  NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: findCurrentPosition
; purpose: Find the current position of the inputArr in the wordBank and update currentWord accordingly
; args:    NONE
; affect:  Modifies currentWord
; return:  NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: PrintInputArr
; purpose: Print the inputArr with green/red colors
; args:    NONE
; affect:  Modifies the color of the current word
; return:  NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: checkInput
; purpose: Check user input against words from the wordBank
; args:    NONE
; affect:  Carry flag
; return:  Sets the carry flag (CF) to indicate whether a match is found or not
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: compareStrings
; purpose: Compare two strings
; args:    esi edi ecx 
; affect:  Carry flag
; return:  Sets the carry flag (CF) to indicate whether the strings are equal or not
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: CheckKey
; purpose: Process the key pressed by the user and update game statistics
; args:    NONE
; affect:  Modifies charsTyped, inputArr, error_count, mistakes, totalInputCount, isWon
; return:  NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: increase_y
; purpose: Increase the y-coordinate of words that are printed in the game
; args:    NONE
; affect:  Modifies arrYcords
; return:  NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: FallingWordGame
; purpose: main purpose of falling word game, combine all the falling word game function that are built for it.
; args:    NONE
; affect:  NONE
; return:  NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: finishMsg
; purpose: Display the appropriate finish message based on game outcome
; args:    NONE
; affect:  NONE
; return:  NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: gameReport
; purpose: Display the game report including mistakes, WPM, accuracy, time taken, and score
; args:    NONE
; affect:  NONE 
; return:  NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: calc_everything
; purpose: Calculate game statistics including WPM, time used, score, and accuracy based on the game type
; args:    NONE
; affect:  Modifies switchGame, WPM, minutes, seconds, score, accuracy
; return:  NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: calc_WPM
; purpose: Calculate the Words Per Minute (WPM) based on the number of words typed and total input count
; args:    NONE
; affect:  Modifies WPM
; return:  NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: calc_Accuracy
; purpose: Calculate the accuracy of the typing based on the total input count and mistakes
; args:    NONE
; affect:  Modifies ACCURACY
; return:  NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: calc_Time_used
; purpose: Calculate the time used for the typing test based on start and end time
; args:    NONE
; affect:  Modifies elapsedTime, minutes, seconds
; return:  NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: convert_Timer_To_Minutes
; purpose: Convert the timer value to minutes and seconds
; args:    NONE
; affect:  Modifies minutes, seconds
; return:  NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: calc_score
; purpose:  Calculate the score based on words typed and mistakes
;           (wordsTyped * 100) - (mistake * 50) = score
; args:    NONE
; affect:  Modifies score
; return:  NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: ask_for_save
; purpose: Prompt the user for their name and whether they want to save the game
; args:    NONE
; affect:  Modifies String_Name, isSave
; return:  NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: saving
; purpose: Save the game result to a file
; args:    NONE
; affect:  Modifies resultCombined, outputFile
; return:  NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: WriteResultToFile
; Purpose: Appends the content stored in resultCombined to a file
; Args:    fileHandle - Handle to the file
;          resultCombined - Pointer to the string containing the content to be written
; Affects: NONE
; Returns: NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: int_to_string
; Purpose: Converts an integer stored in [esi] into a string representation
;          and stores it in the buffer pointed to by edi.
; Args:    esi - Pointer to the integer to be converted
;          edi - Pointer to the buffer where the string will be stored
; Affects: edx, eax, ecx
; Returns: NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: show_Statistics
; Purpose: Reads statistics data from a file and displays it.
; Args:    NONE
; Affects: NONE
; Returns: NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: testing
; Purpose: Provides options to select different game modes, displays corresponding games, and handles the end of the program.
; Args:    NONE
; Affects: NONE
; Returns: NONE
;----------------------------------------------------------------
</pre>
<br/><br/>

<pre>
;----------------------------------------------------------------
; Name: main
; purpose: call testing
; Args:    NONE
; Affects: NONE
; Returns: NONE 
;----------------------------------------------------------------
</pre>
<br/><br/>

