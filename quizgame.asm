; Project: Assembly Quiz Game
; Course: CSE3120
; Authors: Samuel Rock, Thomas Chamberlain
; Date: 2025-11-06
; Assembler: MASM + Irvine32 (x86, 32-bit)
; Summary: Do-or-die Q&A. Correct -> +1 and continue; wrong -> game over.
; Build: Assemble/link with Irvine32 on Windows.
.386
.model flat, stdcall
.stack 4096
INCLUDE Irvine32.inc
NUM_QUESTIONS EQU 10            ; total questions in the quiz

; Data segment: strings, question tables, and game state
.data
startGame BYTE "Ready to start the Assembly Quiz Game?", 0      ; start prompt
 gameOverMSG BYTE "The Game is OVER! Congratulations, your score is: ",0 ; final score banner
correct BYTE "That is correct!", 0                              ; feedback on right answer
incorrect BYTE "That is incorrect.", 0                          ; feedback on wrong answer

animatedTitle BYTE "QUIZ GAME DELUXE GOLD EDITION", 0
titleLength    EQU($ - animatedTitle)

; Colors for feedback
colorDefault  EQU lightGray + black*16
colorCorrect  EQU lightGreen + black*16
colorWrong    EQU lightRed + black*16
colorQuestion EQU yellow + black*16

question1 BYTE "Who created the first assembly programming language?", 13, 10,
  "a: Guido van Rossum", 13, 10,
  "b: James Gosling", 13, 10,
  "c: Kathleen Booth", 13, 10,
  "d: Yukihiro Matsumoto", 0

question2 BYTE "When did assembly first release?", 13, 10,
  "a: 1951", 13, 10,
  "b: 1965", 13, 10,
  "c: 1947", 13, 10,
  "d: 1949", 0

question3 BYTE "What does MASM stand for?", 13, 10,
  "a: Macro System Module", 13, 10,
  "b: Micro Assembly System", 13, 10,
  "c: Machine Assembler", 13, 10,
  "d: Microsoft Macro Assembler", 0

question4 BYTE "What register does pushad save first?", 13, 10,
  "a: EAX", 13, 10,
  "b: EDI", 13, 10,
  "c: ESP", 13, 10,
  "d: EBP", 0

question5 BYTE "In the flags register, what position is the CARRY flag, CF, on?", 13, 10,
  "a: 0", 13, 10,
  "b: 1", 13, 10,
  "c: 6", 13, 10,
  "d: 7", 0

question6 BYTE "The end of a structure declaration is marked with what directive?", 13, 10,
  "a: END", 13, 10,
  "b: ENDS", 13, 10,
  "c: ENDM", 13, 10,
  "d: EXITM", 0

question7 BYTE "What register must you load the address of a string before calling WriteString?", 13, 10,
  "a: EAX", 13, 10,
  "b: EBX", 13, 10,
  "c: ECX", 13, 10,
  "d: EDX", 0

question8 BYTE "When calling ReadChar, which register does the character get stored in?", 13, 10,
  "a: AX", 13, 10,
  "b: AH", 13, 10,
  "c: AL", 13, 10,
  "d: CH", 0

question9 BYTE "What is the escape character in macros?", 13, 10,
  "a: %", 13, 10,
  "b: &", 13, 10,
  "c: #", 13, 10,
  "d: !", 0

question10 BYTE "Which rotation instruction can be used for division by 2 of large multi-byte integers?", 13, 10,
  "a: SHL", 13, 10,
  "b: RCR", 13, 10,
  "c: ROR", 13, 10,
  "d: ROL", 0

questions DWORD OFFSET question1, OFFSET question2, OFFSET question3, OFFSET question4, OFFSET question5, OFFSET question6, OFFSET question7, OFFSET question8, OFFSET question9, OFFSET question10 ; table of question pointers
answers BYTE "cddaabdcdb"                                       ; correct choices (one per question)
prompt BYTE "Enter a, b, c, or d: ", 0                          ; input prompt
questionNumber DWORD 0                                          ; score/current index (0-based)
answered BYTE ?                                                 ; last input from user
qOfPrefix BYTE "Question ", 0                                   ; progress prefix
ofSep     BYTE " of ", 0                                        ; progress separator
allCorrectMsg BYTE "All correct!", 0                            ; perfect run banner
replayPrompt BYTE "Play again? (y/n): ", 0                      ; replay prompt
order BYTE NUM_QUESTIONS DUP(?)

; Code segment: program entry and game flow
.code
RandomOrder PROC
 lea edi, order
 xor ebx, ebx
FillOrder:
 mov al, bl
 mov [edi + ebx], al
 inc ebx
 cmp ebx, NUM_QUESTIONS
 jl FillOrder
 mov ecx, NUM_QUESTIONS
 dec ecx
ShuffleLoop:
 cmp ecx, 0
 jle FinishShuffle
 mov eax, ecx
 inc eax
 call RandomRange
 lea esi, order
 mov dl, [esi + ecx]
 mov bl, [esi + eax]
 mov [esi + ecx], bl
 mov [esi + eax], dl
 dec ecx
 jmp ShuffleLoop
FinishShuffle:
 ret
RandomOrder ENDP

main PROC
 ; ==========================
 ; Animated Title : QUIZ DELUXE GOLD EDITION
 ; ==========================
 mov eax, colorQuestion    ; bright yellow for title
 call SetTextColor

 mov esi, OFFSET animatedTitle
 mov ecx, titleLength      ; number of characters in title

 printTitleLoop:
 mov al, [esi]             ; get current character
 call WriteChar            ; print it
 inc esi
 loop printTitleLoop

 call Crlf
 mov eax, colorDefault
 call SetTextColor
 ; startup: print message and wait for key
 call Randomize

  mov edx, OFFSET startGame
  call WriteString     ; print start message
  call Crlf
  call WaitMsg         ; wait for any key
  call Crlf
  call Crlf            ; blank line

 call RandomOrder

; Display question and possible answers
question:
  mov eax, questionNumber       ; 0-based index
  movzx ecx, byte ptr [order + eax]
  ; progress: "Question X of N"
  mov edx, OFFSET qOfPrefix
  call WriteString
  mov eax, questionNumber
  inc eax                       ; display as 1-based
  call WriteDec
  mov edx, OFFSET ofSep
  call WriteString
  mov eax, NUM_QUESTIONS
  call WriteDec
  call Crlf
  mov esi, OFFSET questions      ; load pointer to question text
  mov edx, [esi + ecx*4]
  call WriteString               ; print question + options
  call Crlf
  mov eax, colorQuestion
  call SetTextColor

; Prompt and get answer
  mov edx, OFFSET prompt        ; prompt for a/b/c/d
  call WriteString
  call ReadChar                 ; AL = input char
  mov answered, al              ; save input
  call Crlf

; Check answer, if wrong end gane, if correct move on to next question
  mov esi, OFFSET answers       ; BL = correct char for this question
  mov eax, questionNumber
  movzx ecx, byte ptr [order + eax]
  mov bl, [esi + ecx]
  cmp answered, bl
  jne incorrectAnswer           ; wrong -> game over

  mov eax, colorCorrect
  call SetTextColor        ; set green for correct
  mov edx, OFFSET correct
  call WriteString
  call Crlf
  mov eax, colorDefault
  call SetTextColor        ; reset to default
  inc questionNumber            ; +1 score, move to next
  cmp questionNumber, NUM_QUESTIONS
  jge gameIsOver
  call Crlf
  jmp question

incorrectAnswer:
  mov eax, colorWrong
  call SetTextColor        ; set red for wrong
  mov edx, OFFSET incorrect
  call WriteString
  call Crlf
  mov eax, colorDefault
  call SetTextColor        ; reset to default
  jmp gameIsOver


;game over procedure
gameIsOver:
  cmp questionNumber, NUM_QUESTIONS ; perfect run?
  jne skipPerfect
  mov edx, OFFSET allCorrectMsg
  call WriteString
  call Crlf
skipPerfect:
  mov edx, OFFSET gameOverMSG   ; final score banner
  call WriteString
  mov eax, questionNumber       ; print score
  call WriteDec
  call Crlf
  mov edx, OFFSET replayPrompt  ; ask to replay
  call WriteString
  call ReadChar
  cmp al, 'y'                   ; Y/y -> replay
  je doReplay
  cmp al, 'Y'
  je doReplay
  call Crlf
  exit                          ; quit

doReplay:
  call Crlf
  mov questionNumber, 0         ; reset score/index
  call RandomOrder              ; Rerandomize the order for the replay
  call Crlf
  jmp question

main ENDP
END main
