; Quiz Game
.386
.model flat, stdcall
.stack 4096
INCLUDE Irvine32.inc

; questions and answers
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

questions DWORD OFFSET question1, OFFSET question2, OFFSET question3, OFFSET question4
answers BYTE "cdda"
prompt BYTE "Enter a, b, c, or d: ", 0
questionNumber DWORD 0
answered BYTE ?

; main program
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
  call Crlf ; blank line for next question
  inc questionNumber ; increment score
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
