; Quiz Game
.386
.model flat, stdcall
.stack 4096
INCLUDE Irvine32.inc

; questions and answers
.data
startGame BYTE "Ready to start the Assembly Quiz Game?", 0

; main program
.code
main PROC
  mov edx, OFFSET startGame
  call WriteString   ; print out startGame message
  call Crlf
  call WaitMsg   ; wait for user to start with enter
  call Crlf

; Display question and possible answers


; Prompt answer


; Check answer, if wrong end gane, if correct move on to next question

main ENDP
END main
