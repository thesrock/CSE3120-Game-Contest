; Project: Assembly Quiz Game
; Course: CSE3120
; Authors: Samuel Rock, Thomas Chamberlain, Lawson Darrow
; Date: 2025-11-06
; Assembler: MASM + Irvine32 (x86, 32-bit)
; Summary: Do-or-die Q&A. Correct -> +1 and continue; wrong -> game over.
; Build: Assemble/link with Irvine32 on Windows.
.386
.model flat, stdcall
.stack 4096
INCLUDE Irvine32.inc

NUM_QUESTIONS EQU 10

; Data segment: strings, question tables, and game state
.data
startGame BYTE "Ready to start the Assembly Quiz Game?", 0
gameOverMSG BYTE "The Game is OVER! Congradulations, your score is: ",0
correct BYTE "That is correct!", 0
incorrect BYTE "That is incorrect.", 0

question1 BYTE "1: Who created the first assembly programming language?", 13, 10,
  "a: Guido van Rossum", 13, 10,
  "b: James Gosling", 13, 10,
  "c: Kathleen Booth", 13, 10,
  "d: Yukihiro Matsumoto", 0

question2 BYTE "2: When did assembly first release?", 13, 10,
  "a: 1951", 13, 10,
  "b: 1965", 13, 10,
  "c: 1947", 13, 10,
  "d: 1949", 0

question3 BYTE "3: What does MASM stand for?", 13, 10,
  "a: Macro System Module", 13, 10,
  "b: Micro Assembly System", 13, 10,
  "c: Machine Assembler", 13, 10,
  "d: Microsoft Macro Assembler", 0

question4 BYTE "4: What register does pushad save first?", 13, 10,
  "a: EAX", 13, 10,
  "b: EDI", 13, 10,
  "c: ESP", 13, 10,
  "d: EBP", 0

question5 BYTE "5: In the flags register, what position is the CARRY flag, CF, on?", 13, 10,
  "a: 0", 13, 10,
  "b: 1", 13, 10,
  "c: 6", 13, 10,
  "d: 7", 0

question6 BYTE "6: The end of a structure declaration is marked with what directive?", 13, 10,
  "a: END", 13, 10,
  "b: ENDS", 13, 10,
  "c: ENDM", 13, 10,
  "d: EXITM", 0

question7 BYTE "7: What register must you load the address of a string before calling WriteString?", 13, 10,
  "a: EAX", 13, 10,
  "b: EBX", 13, 10,
  "c: ECX", 13, 10,
  "d: EDX", 0

question8 BYTE "8: When calling ReadChar, which register does the character get stored in?", 13, 10,
  "a: AX", 13, 10,
  "b: AH", 13, 10,
  "c: AL", 13, 10,
  "d: CH", 0

question9 BYTE "9: What is the escape character in macros?", 13, 10,
  "a: %", 13, 10,
  "b: &", 13, 10,
  "c: #", 13, 10,
  "d: !", 0

question10 BYTE "10: Which rotation instruction can be used for division by 2 of large multi-byte integers?", 13, 10,
  "a: SHL", 13, 10,
  "b: RCR", 13, 10,
  "c: ROR", 13, 10,
  "d: ROL", 0

questions DWORD OFFSET question1, OFFSET question2, OFFSET question3, OFFSET question4, OFFSET question5, OFFSET question6, OFFSET question7, OFFSET question8, OFFSET question9, OFFSET question10
answers BYTE "cddaabdcdb"
prompt BYTE "Enter a, b, c, or d: ", 0
questionNumber DWORD 0
answered BYTE ?

; Code segment: program entry and game flow
.code
main PROC
  mov edx, OFFSET startGame
  call WriteString   ; print out startGame message
  call Crlf
  call WaitMsg   ; wait for user to start with any key press
  call Crlf
  call Crlf   ; creates a blank line

; Display question and possible answers
question:
  mov ecx, questionNumber
  mov eax, OFFSET questions
  mov edx, [eax + ecx*4]
  call WriteString
  call Crlf

; Prompt and get answer
  mov edx, OFFSET prompt
  call WriteString
  call ReadChar ; get input from user, their answer goes into al
  mov answered, al ; save user answer into answered
  call Crlf

; Check answer, if wrong end gane, if correct move on to next question
  mov eax, OFFSET answers
  mov ecx, questionNumber
  mov bl, [eax + ecx]
  cmp answered, bl
  jne incorrectAnswer ; if incorrect

  mov edx, OFFSET correct ; correct answer
  call WriteString ; print that answer was correct
  call Crlf
  inc questionNumber ; increment score
  cmp questionNumber, NUM_QUESTIONS ; end when all answers correct
  jge gameIsOver
  call Crlf ; blank line for next question
  jmp question ; next question

incorrectAnswer:
  mov edx, OFFSET incorrect ; incorrect answer
  call WriteString ; print that answer was incorrect
  call Crlf
  jmp gameIsOver


;game over procedure
gameIsOver:
  mov edx, OFFSET gameOverMSG;load the final game message
  call WriteString; call the final game message
  mov eax, questionNumber; load the score
  call WriteDec; call the score
  call Crlf
  call WaitMsg; irvine32 variable that waits so ppl can read the final score
  exit; exit the game now

main ENDP
END main
