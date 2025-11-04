; Quiz Game
.386
.model flat, stdcall
.stack 4096
INCLUDE Irvine32.inc

; questions and answers
.data
startGame BYTE "Ready to start the Assembly Quiz Game?", 0

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

questions DWORD OFFSET question1, OFFSET question2
answers BYTE "cd"
prompt BYTE "Enter a, b, c, or d: ", 0
questionNumber DWORD 0

; main program
.code
main PROC
  mov edx, OFFSET startGame
  call WriteString   ; print out startGame message
  call Crlf
  call WaitMsg   ; wait for user to start with enter
  call Crlf
  call Crlf   ; creates a blank line

; Display question and possible answers
question:
  mov ecx, questionNumber
  mov eax, OFFSET questions
  mov edx, [eax + ecx*4]
  call WriteString
  call Crlf

; Prompt answer
  mov edx, OFFSET prompt
  call WriteString

; Check answer, if wrong end gane, if correct move on to next question

;game over procedure
gameOverMSG BYTE "The Game is OVER! Congradulations, your score is: ",0
gameIsOver:
  mov edx, OFFSET gameOverMSG;load the final game message
  call WriteString; call the final game message
  mov eax, questionNumber; load the score
  call WriteDec; call the score
  call WaitMsg; irvine32 variable that waits so ppl can read the final score
  exit; exit the game now

main ENDP
END main
