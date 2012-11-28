*-----------------------------------------------------------
* Program Number: 7
* Written by    : Eric Wright, Chris Hoehn, Jerry Daru
* Date Created  : 12/17/11
* Description   : Play a game of blackjack against the computer
*
*-----------------------------------------------------------
START	ORG	$1000
	
	MOVE.B	#13,D0		: Displays the welcome message. Only displays on the first game
	LEA	welcome,A1
	TRAP	#15

NEWHAND	MOVE.B	#0,D3		:zero out D3 used to preserve randomness NOTE without this the code will generate the same number several times due to execution speed

DRAW	CLR.L	D1		:clear the data from D1 to get clock data
	MOVE.B	#8,D0		:load task 8 (get clock)
	TRAP	#15		:execute task 8, D1 now contains time in 100ths of a second
	MOVE.W	D1,D5		:move clock data to D5 for manipulation
	SWAP	D5		:swap lower order and higher order of D6 NOTE this is done to preserve data for second pass
	CLR.W	D5		:clear only the lower order of D5
	SWAP	D5		:swap lower and higher order of D5 back to original places
	ADD.W	D3,D5		:add value of D3 to D5 part of preserving randomness
	ADD.W	#4,D3		:increment D3 by 4 so next time it is added it is different
	DIVU	#13,D5		:divide clock data in D5 by 13
	SWAP	D5		:swap D5 so only remainder is seen in .W
	ADD.W	#2,D5		:add 2 to mod 13 so result is 2-14 instead of 0-12

CHECK1	CMP.W	#10,D5		:check if result of mod is greater than 10
	BGT	CHECK2		:if greater than 10 jump to 2nd check
	ADD.W	D5,D7		:if not greater add value of D5 to D7(players score)
	BRA	PCHECK

CHECK2	CMP.W	#11,D5		: check if result is greater than 11
	BGT	CHECK3
	ADD.W	#10,D7
	BRA	PCHECK

CHECK3	CMP.W	#12,D5		: check if result is greater than 12
	BGT	CHECK4
	ADD.W	#10,D7
	BRA	PCHECK

CHECK4	CMP.W	#13,D5		: check if result is greater than 13
	BGT	PACECHK
	ADD.W	#10,D7
	BRA	PCHECK

PACECHK	CMP.W	#10,D7		: check the the ace should add 11 or 1 to the players total
	BGT	PADD1
	ADD.W	#11,D7
	

PCHECK	CMP.W	#21,D7		: check to see if the player busts
	BGT	PLOSE
	CMP.W	#21,D7		: check to see if the player got 21
	BEQ	DLOSE

PSHOW	MOVE.B	#17,D0		: this section of code will display the players total with each new card
	LEA	player,A1
	CLR.L	D1
	MOVE.B	D7,D1
	TRAP	#15

NEWCARD	LEA	newline,A1	: NEWCARD asks if the player wants a new card.
	MOVE.W	#13,D0
	TRAP	#15
	LEA	hit,A1
	TRAP	#15
	MOVE.L	#1,D1		:set D1 to 1, for task 7 to set keyboard to active (listening for input)
	MOVE.B	#7,D0		:load task 7 to retreive one character input from keyboard
	TRAP	#15		:execute task 7
	MOVE.B	#5,D0		:load task 5 into D0 (actual character input if D1 is used to make keyboard active
	TRAP	#15		:execute task 5
	LEA	newline,A1
	MOVE.W	#13,D0
	TRAP	#15
	CMP.B	#$79,D1		:compare D1 with the hex value for 'y'
	BNE	DLRTURN		:if not equal to 'y' players turn over
	BRA	DRAW

DLRTURN	LEA	dturn,A1	: Declare that the dealers turn is starting
	MOVE.W	#13,D0
	TRAP	#15

DDRAW	CLR.L	D1		:clear the data from D1 to get clock data
	MOVE.B	#8,D0		:load task 8 (get clock)
	TRAP	#15		:execute task 8, D1 now contains time in 100ths of a second
	MOVE.W	D1,D5		:move clock data to D5 for manipulation
	SWAP	D5		:swap lower order and higher order of D6 NOTE this is done to preserve data for second pass
	CLR.W	D5		:clear only the lower order of D5
	SWAP	D5		:swap lower and higher order of D5 back to original places
	ADD.W	D3,D5		:add value of D3 to D5 part of preserving randomness
	ADD.W	#4,D3		:increment D3 by 4 so next time it is added it is different
	DIVU	#13,D5		:divide clock data in D5 by 13
	SWAP	D5		:swap D5 so only remainder is seen in .W
	ADD.W	#2,D5		:add 2 to mod 13 so result is 2-14 instead of 0-12

DCHECK1	CMP.W	#10,D5		:check if result of mod is greater than 10
	BGT	DCHECK2		:if greater than 10 jump to 2nd check
	ADD.W	D5,D6		:if not greater add value of D5 to D7(players score)
	BRA	DCMP

DCHECK2	CMP.W	#11,D5		: check if result is greater than 11
	BGT	DCHECK3
	ADD.W	#10,D6
	BRA	DCMP

DCHECK3	CMP.W	#12,D5		: check if result is greater than 12
	BGT	DCHECK4
	ADD.W	#10,D6
	BRA	DCMP

DCHECK4	CMP.W	#13,D5		: check if result is greater than 13
	BGT	DACECHK
	ADD.W	#10,D6
	BRA	DCMP

DACECHK	CMP.W	#10,D6		: check if the ace should add 11 to the dealers total or 1
	BGT	DADD1
	ADD.W	#11,D6

DCMP	CMP.W	#21,D6		: check if the dealer busts
	BGT	DLOSE
	CMP.W	#21,D6		: check if the dealer got 21
	BEQ	PLOSE

DSHOW	LEA	newline,A1	: shows the dealers total after each new card
	MOVE.W	#13,D0
	TRAP	#15
	MOVE.B	#17,D0
	LEA	dealer,A1
	CLR.L	D1
	MOVE.B	D6,D1
	TRAP	#15

CHKWIN	CMP.W	D6,D7		: compares the dealers total to the players.
	BGT	DDRAW		: If the dealer is currently below the player the dealer draws again (this spot can only be reached of the player hasn't busted).
	BRA	PLOSE		: if the dealer has a higher total than the player then the dealer wins 






PLOSE	LEA	newline,A1	: PLOSE is called in any case where the player loses.
	MOVE.W	#13,D0
	TRAP	#15

	LEA	dashes,A1	: prints a line of dashes to separate the hands from the final scores
	MOVE.W	#13,D0
	TRAP	#15

	MOVE.B	#17,D0		: displays the players final score
	LEA	player,A1
	CLR.L	D1
	MOVE.B	D7,D1
	TRAP	#15

	LEA	newline,A1	: dislplays a blank line for readability
	MOVE.W	#13,D0
	TRAP	#15


	MOVE.B	#17,D0		: displays the dealers final score
	LEA	dealer,A1
	CLR.L	D1
	MOVE.B	D6,D1
	TRAP	#15

	LEA	newline,A1	: adds a blank line and tells the player s/he lost
	MOVE.W	#13,D0
	TRAP	#15
	LEA	pbust,A1
	MOVE.W	#13,D0
	TRAP	#15
	BRA	NEW		: Branch to the option to start a new game

DLOSE	LEA	newline,A1	: DLOSE is called when the dealer loses
	MOVE.W	#13,D0
	TRAP	#15

	LEA	dashes,A1	: displays a line of dashes to separate the hands from the final scores
	MOVE.W	#13,D0
	TRAP	#15

	MOVE.B	#17,D0		: displays the dealers final total
	LEA	dealer,A1
	CLR.L	D1
	MOVE.B	D6,D1
	TRAP	#15
	LEA	newline,A1
	MOVE.W	#13,D0
	TRAP	#15
	LEA	dbust,A1	: tell the player s/he won
	MOVE.W	#13,D0
	TRAP	#15
	BRA	NEW		: Branchs to NEW to ask the player if s/he would like to play again

PADD1	ADD.W	#1,D7		: adds 1 to the players total from the ace
	BRA	PCHECK

DADD1	ADD.W	#1,D6		: adds 1 to the dealers total from the ace
	BRA	DCMP
	
NEW	LEA	newline,A1	: NEW is called when the game ends. The player will be asked if s/he wishes to play again.
	MOVE.W	#13,D0
	TRAP	#15

	LEA	again,A1
	TRAP	#15

	MOVE.L	#1,D1		:set D1 to 1, for task 7 to set keyboard to active (listening for input)
	MOVE.B	#7,D0		:load task 7 to retreive one character input from keyboard
	TRAP	#15		:execute task 7
	MOVE.B	#5,D0		:load task 5 into D0 (actual character input if D1 is used to make keyboard active
	TRAP	#15		:execute task 5

	LEA	newline,A1
	MOVE.W	#13,D0
	TRAP	#15
	CMP.B	#$79,D1		:compare D1 with the hex value for 'y'
	BNE	EXIT		:if not equal to 'y' players turn over
	
	MOVE.W 	#$FF00,D1	: this block of code will clear the screen then clear all the registers used
	MOVE.B	#11,D0
	TRAP	#15
	CLR.L	(A1)
	CLR.L	D0
	CLR.L	D1
	CLR.L	D2
	CLR.L	D3
	CLR.L	D4
	CLR.L	D5
	CLR.L	D6
	CLR.L	D7

	BRA	NEWHAND		: this will send the player back to the top to play a new game if the player chose to do so




EXIT	MOVE.B	#9,D0
	TRAP	#15		Halt Simulator


	ORG	$4000		: Below here we have our strings. CR and LF are the constants for the ASCII codes to carriage return and line feed

CR	EQU	$0D
LF	EQU	$0A
welcome	DC.L	'Your playing assembly Blackjack', CR, LF, 0
player	DC.L	'Player: ', CR, LF, 0
dealer	DC.L	'Dealer: ', CR, LF, 0
hit	DC.L	'Hit?', CR, LF, 0
pbust	DC.L	'YOU LOST!', CR, LF, 0
dbust	DC.L	'You win! You are something else kid!', CR, LF, 0
dturn	DC.L	'Dealer begins drawing', CR, LF, 0
newline	DC.L	'', CR, LF, 0
dashes	DC.L	'--------------------------', CR, LF, 0
again	DC.L	'Want to play again?', CR, LF, 0

	END	START
*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~8~
