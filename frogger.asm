#####################################################################
#
# CSC258H5S Winter 2022 Assembly Final Project
# University of Toronto, St. George
#
# Student: Michael Umeh, 1007039152
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 256
# - Display height in pixels: 256
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestone is reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 5
#
# Which approved additional features have been implemented?
# (See the assignment handout for the list of additional features)
# 1. Display Score (Hard)
# 2. Two player (Hard)
# 3. Display number of lives (Easy)
# 4. Retry option screen (Easy)
# 5. Sound Effects (Easy)
# Any additional information that the TA needs to know:
# - Second pink frog can me controlled with i, j, k, l, keys for collaborative two player mode
# - Success area is the top most row, and is divded into 8 equal squares, frog must be flush with
#   a succes square to score
# - Player wins after 8 points are scored, one for each filled square
#####################################################################

.data
drawing: .word 0:32
displayAddress: .word 0x10008000
frog_x: .word 64
frog_y: .word 3584
bfrog_x: .word 48
bfrog_y: .word 3584
top_logs: .word 0:32
bottom_logs: .word 0:32
top_vehicles: .word 0:32
bottom_vehicles: .word 0:32
poffset: .word 0
noffset: .word 0
buffer: .space 4096
lives: .word 3:1
success: .word 0:8
points: .word 0:1
speed: .word 0
.text
main:
######################################################################################################################
# chekcing keyboard input

lw $t8, 0xffff0000 # access indicator register
beq $t8, 1, keyboard_input # check if there input
j finish
keyboard_input: 
                lw $t2, 0xffff0004 # check input value
                beq $t2, 0x61, respond_to_A
                beq $t2, 0x77, respond_to_W
                beq $t2, 0x64, respond_to_D
                beq $t2, 0x73, respond_to_S
                beq $t2, 0x6A, respond_to_j
                beq $t2, 0x69, respond_to_i
                beq $t2, 0x6C, respond_to_l
                beq $t2, 0x6B, respond_to_k
                j finish
respond_to_W: la $t0, frog_x # load frog coords
              la $t1, frog_y
              lw $t3, 0($t0) # t3 x coord
              lw $t4, 0($t1) # t4 y coord
              add $t5, $zero, $zero
              beq $t4, $t5, finish
              jal movement_sound
              addi $t4, $t4, -512
              sw $t4, 0($t1)
              j finish
respond_to_i: la $t0, bfrog_x # load frog coords
              la $t1, bfrog_y
              lw $t3, 0($t0) # t3 x coord
              lw $t4, 0($t1) # t4 y coord
              add $t5, $zero, $zero
              beq $t4, $t5, finish
              jal movement_sound
              addi $t4, $t4, -512
              sw $t4, 0($t1)
              j finish
respond_to_S: la $t0, frog_x # load frog coords
              la $t1, frog_y
              lw $t3, 0($t0) # t3 x coord
              lw $t4, 0($t1) # t4 y coord
              addi $t5, $zero, 3584
              beq $t4, $t5, finish
              jal movement_sound
              addi $t4, $t4, 512
              sw $t4, 0($t1)
              j finish
respond_to_k: la $t0, bfrog_x # load frog coords
              la $t1, bfrog_y
              lw $t3, 0($t0) # t3 x coord
              lw $t4, 0($t1) # t4 y coord
              addi $t5, $zero, 3584
              beq $t4, $t5, finish
              jal movement_sound
              addi $t4, $t4, 512
              sw $t4, 0($t1)
              j finish
respond_to_A: la $t0, frog_x # load frog coords
              la $t1, frog_y
              lw $t3, 0($t0) # t3 x coord
              lw $t4, 0($t1) # t4 y coord
              add $t5, $zero, $zero
              beq $t3, $t5, finish
              jal movement_sound
              addi $t3, $t3, -4
              sw $t3, 0($t0)
              j finish
respond_to_j: la $t0, bfrog_x # load frog coords
              la $t1, bfrog_y
              lw $t3, 0($t0) # t3 x coord
              lw $t4, 0($t1) # t4 y coord
              add $t5, $zero, $zero
              beq $t3, $t5, finish
              jal movement_sound
              addi $t3, $t3, -4
              sw $t3, 0($t0)
              j finish
respond_to_D: la $t0, frog_x # load frog coords
              la $t1, frog_y
              lw $t3, 0($t0) # t3 x coord
              lw $t4, 0($t1) # t4 y coord
              addi $t5, $zero, 112
              beq $t3, $t5, finish
              jal movement_sound
              addi $t3, $t3, 4
              sw $t3, 0($t0)
              j finish
respond_to_l: la $t0, bfrog_x # load frog coords
              la $t1, bfrog_y
              lw $t3, 0($t0) # t3 x coord
              lw $t4, 0($t1) # t4 y coord
              addi $t5, $zero, 112
              beq $t3, $t5, finish
              jal movement_sound
              addi $t3, $t3, 4
              sw $t3, 0($t0)
finish: 
######################################################################################################################

# collistion detecton
add $s0, $zero, $zero
add $s2, $zero, $zero
add $s3, $zero, $zero 
jal collision_detection
jal bcollision_detection


######################################################################################################################

# check success
add $s1, $zero, $zero
jal check_success



######################################################################################################################
# initilize useful drawing array
addi $t0, $zero, 7
add $t2, $zero, $zero
la $t3, drawing
for: bgt $t2, $t0, next
     sw $t2, 0($t3)
loop: addi $t2, $t2, 1
      addi $t3, $t3, 4
      j for
next:

addi $t0, $zero, 23
addi $t2, $zero, 16
la $t3, drawing
addi $t3, $t3, 64
for2: bgt $t2, $t0, next2
     sw $t2, 0($t3)
loop2: addi $t2, $t2, 1
      addi $t3, $t3, 4
      j for2
next2:



######################################################################################################################
# draw ending
la $a0, buffer
li $a1, 1024
addi $a3, $zero, 0x00ff00
jal draw_background

# draw success
jal draw_success

la $a0, buffer
addi $a0, $a0, 1024

# draw water
li $a1, 1024
addi $a3, $zero, 0x0000ff 
jal draw_background


# draw safe zone
li $a1, 512
li $a3, 0xffff00
jal draw_background

# draw road
li $a1, 1024
li $a3, 0x161616
jal draw_background

# draw start zone
li $a1, 512
addi $a3, $zero, 0x00ff00
jal draw_background



######################################################################################################################

# afix log locations for top river

la $a0, top_logs
jal wipe # clear array

la $a0, top_logs
lw $t1, poffset
add $a0, $a0, $t1 # find new log positions

la $a1, top_logs
add $a1, $a1, 124 # pass boundary address

jal draw_obstacles1

la $a0, buffer
addi $a0, $a0, 1024 # drawing location
li $a1, 0x964B00
li $a2, 0x0000ff 
la $a3, top_logs
jal draw_rectangles
 


######################################################################################################################

# afix log locations for bottom river

la $a0, bottom_logs
jal wipe # clear array

la $a0, bottom_logs
lw $t1, noffset
addi $a0, $a0, 124
add $a0, $a0, $t1 # find new log positions

la $a1, bottom_logs # pass boundary address

jal draw_obstacles2

la $a0, buffer
addi $a0, $a0, 1536 # drawing location
li $a1, 0x964B00
li $a2, 0x0000ff 
la $a3, bottom_logs
jal draw_rectangles

######################################################################################################################

# afix vehicle locations for top road
la $a0, top_vehicles
jal wipe # clear array

la $a0, top_vehicles
lw $t1, noffset
addi $a0, $a0, 12
add $a0, $a0, $t1 # find new log positions

la $a1, top_vehicles # pass boundary address

jal draw_obstacles2

la $a0, buffer
addi $a0, $a0, 2560 # drawing location
li $a1, 0xff0000
li $a2, 0x161616
la $a3, top_vehicles
jal draw_rectangles

######################################################################################################################

# afix vehicle locations for bottom road

la $a0, bottom_vehicles
jal wipe # clear array

la $a0, bottom_vehicles
lw $t1, poffset
addi $a0, $a0, 16
add $a0, $a0, $t1 # find new log positions

la $a1, bottom_vehicles
add $a1, $a1, 124 # pass boundary address

jal draw_obstacles1

la $a0, buffer
addi $a0, $a0, 3072 # drawing location
li $a1, 0xff0000
li $a2, 0x161616
la $a3, bottom_vehicles
jal draw_rectangles

#######################################################################################################################
# draw frog
jal draw_frog
jal draw_frog2
######################################################################################################################
# draw points

la $a0, buffer
addi $a0, $a0, 116
la $t0, points
lw $a1, 0($t0)
li $a2, 0xffffff
jal draw_numbers
######################################################################################################################
# draw lives

la $a0, buffer
la $t0, lives
lw $a1, 0($t0)
li $a2, 0xffffff
jal draw_numbers
######################################################################################################################
# draw buffer

jal draw_buffer

######################################################################################################################


# collision and success acountability
collision_acountability:
beq $s1, 1, big_clear

beq $s0, 1, big_clear # if a collision occured, jump to big_clear
j forward
big_clear: add $t0, $zero, $zero 
           addi $t1, $zero, 3584
           addi $t2, $zero, 64
           la $t3, frog_x
           la $t4, frog_y
           la $t5, poffset
           la $t6, noffset
           sw $t0, 0($t5)
           sw $t0, 0($t6)
           sw $t1, 0($t4)
           sw $t2, 0($t3) 
           addi $t1, $zero, 3584
           addi $t2, $zero, 48
           la $t3, bfrog_x
           la $t4, bfrog_y
           sw $t1, 0($t4)
           sw $t2, 0($t3) 
           
           
           # positions of obstacles and frogs reset
           
           beq $s1, 1, check_points # no need to update lives in the event of sucess
           la $t0, lives
           lw $t1, 0($t0)
           li $t3, 1
           sub $t1, $t1, $t3
           sw $t1, 0($t0)
           beq $t1, $zero, oh_no
           j sleep
           oh_no:  # play sound
               li $v0, 31   
               li $a0, 69
               li $a1, 10000
               li $a2, 127
               li $a3, 60
               syscall
           add $a1, $zero, 0
               j retry_loop
check_points: la $t0, points
              lw $t1, 0($t0)
              beq $t1, 8, lets_goo # player as won game 
              j forward
lets_goo:          # play sound
               li $v0, 31   
               li $a0, 69
               li $a1, 2500
               li $a2, 80
               li $a3, 60
               syscall
               add $a1, $zero, 1
               j retry_loop
######################################################################################################################
forward: lw $t0, speed
         bne $t0, 29, update_speed
         la $t1, speed
         sw $zero, 0($t1)
         j forward_fr
update_speed: la $t1, speed
              addi $t0, $t0, 1
              sw $t0, 0($t1)
              j no_update


# moving forward
forward_fr: la $t0, poffset # get address
         lw $t1, poffset # get value
         addi $t2, $zero, 124
         beq $t1, $t2, reset # if offset is 124 currently
         addi $t1, $t1, 4  #new value
         j save
reset: add $t1, $zero, $zero
save: sw $t1 0($t0) #save new value

# moving backward
backward: la $t0, noffset # get address
          lw $t1, noffset # get value
          addi $t2, $zero, -124
          beq $t1, $t2, reset2 # if offset is 124 currently
          addi $t1, $t1, -4  #new value
          j save2
reset2: add $t1, $zero, $zero
save2: sw $t1 0($t0) #save new value


no_update: j sleep

######################################################################################################################

# game end loop

retry_loop: 
check_q: lw $t8, 0xffff0000 # access indicator register
         beq $t8, 1, retry_keyboard_input # check if there input
         j draw_game_end
retry_keyboard_input: lw $t2, 0xffff0004 # check input value
                      beq $t2, 0x71, respond_to_q
                      j draw_game_end
respond_to_q: add $t0, $zero, $zero 
              addi $t1, $zero, 3584
              addi $t2, $zero, 64
              la $t3, frog_x
              la $t4, frog_y
              la $t5, poffset
              la $t6, noffset
              sw $t0, 0($t5)
              sw $t0, 0($t6)
              sw $t1, 0($t4)
              sw $t2, 0($t3) 
              addi $t1, $zero, 3584
              addi $t2, $zero, 48
              la $t3, bfrog_x
              la $t4, bfrog_y
              sw $t1, 0($t4)
              sw $t2, 0($t3) 
              # lives: .word 3:1
              la $t0, lives
              addi $t1, $zero, 3
              sw $t1, 0($t0)
              # success: .word 0:8
              la $t0, success
              add $t1, $zero, $zero
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              # points: .word 0:1
              la $t0, points
              add $t1, $zero, $zero
              sw $t1, 0($t0)
              j main    
draw_game_end: beq $a1, 1, winner
               la $a0, buffer
               addi $a0, $a0, 1548
               jal draw_press_q
               
               la $a0, buffer
               addi $a0, $a0, 780
               jal draw_retry
               j loop_end_screen
               
winner:        la $a0, buffer
               addi $a0, $a0, 1548
               jal draw_press_q
               
               la $a0, buffer
               addi $a0, $a0, 780
               jal draw_restart
               j loop_end_screen
                 
loop_end_screen: jal draw_buffer
                 j retry_loop
######################################################################################################################

# Sleep
sleep: li $v0, 32
       li $a0, 17    # 17 ms = ~60 FPS
       syscall        # Sleep for $a0 ms
       j main
######################################################################################################################


draw_background: add $t5, $zero, $zero # initailize loop variable
                 add $t9, $zero, $a1 # set rectangle size
start: beq $t5, $t9, Return # exit once finished drawing
       sw $a3 0($a0) # color area 
       addi $a0, $a0, 4 #increment pixel
update: addi $t5, $t5, 4 #increment loop variable
	j start
Return: jr $ra

######################################################################################################################

draw_frog: la $t5, buffer # initialize posittion variable
           lw $t7, frog_x
           lw $t8, frog_y
           add $t5, $t5, $t7 # move to approprate row position
           add $t5, $t5, $t8 # move to appropriate column position
           li $t6, 0x6a0dad # load purple color
           sw $t6 0($t5) # color top left pizel
           addi $t5, $t5, 12 # top right pixel
           sw $t6 0($t5)
           addi $t5, $t5, 128 # first middle right pixel
           sw $t6 0($t5)
           addi $t5, $t5, -4 
           sw $t6 0($t5)
           addi $t5, $t5, -4
           sw $t6 0($t5)
           addi $t5, $t5, -4
           sw $t6 0($t5)
           addi $t5, $t5, 132 # second middle middle pixel
           sw $t6 0($t5)
           addi $t5, $t5, 4 # 
           sw $t6 0($t5)
           addi $t5, $t5, 120# bottom left pixel
           sw $t6 0($t5)
           addi $t5, $t5, 4 
           sw $t6 0($t5)
           addi $t5, $t5, 4 
           sw $t6 0($t5)
           addi $t5, $t5, 4 
           sw $t6 0($t5)
Return2: jr $ra
######################################################################################################################

draw_frog2: la $t5, buffer # initialize posittion variable
           lw $t7, bfrog_x
           lw $t8, bfrog_y
           add $t5, $t5, $t7 # move to approprate row position
           add $t5, $t5, $t8 # move to appropriate column position
           li $t6, 0xFFC0CB # load purple color
           sw $t6 0($t5) # color top left pizel
           addi $t5, $t5, 12 # top right pixel
           sw $t6 0($t5)
           addi $t5, $t5, 128 # first middle right pixel
           sw $t6 0($t5)
           addi $t5, $t5, -4 
           sw $t6 0($t5)
           addi $t5, $t5, -4
           sw $t6 0($t5)
           addi $t5, $t5, -4
           sw $t6 0($t5)
           addi $t5, $t5, 132 # second middle middle pixel
           sw $t6 0($t5)
           addi $t5, $t5, 4 # 
           sw $t6 0($t5)
           addi $t5, $t5, 120# bottom left pixel
           sw $t6 0($t5)
           addi $t5, $t5, 4 
           sw $t6 0($t5)
           addi $t5, $t5, 4 
           sw $t6 0($t5)
           addi $t5, $t5, 4 
           sw $t6 0($t5)
Returnfrog2: jr $ra
######################################################################################################################

wipe: add $t0, $zero, $zero # initialize loop variable i
      add $t1, $zero, $zero # initialize wipe value
      addi $t2, $zero, 128
start3: beq $t0, $t2, return3 # if i == 128, exit
       add $t3, $a0, $t0 # t4 = adr(array[i])
       sw $t1, 0($t3) # array[i] = 0
update3: addi $t0, $t0, 4
        j start3
return3: jr $ra

######################################################################################################################
draw_obstacles1: add $t0, $zero, $zero # initialize loop variable i
                addi $t1, $zero, 32 # termination condition
                la $a2, drawing # use drawing array
                add $t2, $zero, $a0 # current array address
                addi $t4, $zero, 1 # drawing bit
start4: beq $t0, $t1, return4 # if i == 32 exit
        lw $t3, 0($a2) # load drawing array value
check: bgt $t2, $a1, wrap_around # jump to wrap around if address out of bounds
       j draw # else proceed with drawing
wrap_around: addi, $t2, $t2, -128 # shift values back
draw: bne $t0, $t3, update4 # draw out obstacle
      sw $t4, 0($t2) 
update4: addi $t0, $t0, 1
         addi $a2, $a2, 4
         addi $t2, $t2, 4
loop4: j start4
return4: jr $ra
######################################################################################################################
draw_obstacles2: add $t0, $zero, $zero # initialize loop variable i
                 addi $t1, $zero, 32 # termination condition
                 la $a2, drawing # use drawing array
                 add $t2, $zero, $a0 # current array address
                 addi $t4, $zero, 1 # drawing bit
start6: beq $t0, $t1, return6# if i == 32 exit
        lw $t3, 0($a2) # load drawing array value
check6: bgt $a1, $t2, wrap_around2 # jump to wrap around if address out of bounds
       j draw6 # else proceed with drawing
wrap_around2: addi $t2, $t2, 128 # shift values back
draw6: bne $t0, $t3, update6 # draw out obstacle
      sw $t4, 0($t2) 
update6: addi $t0, $t0, 1
         addi $a2, $a2, 4
         addi $t2, $t2, -4
loop6: j start6
return6: jr $ra
######################################################################################################################
draw_rectangles: add $t0, $zero, $zero # initialize loop variable i
                 addi $t1, $zero, 4
                 addi $t4, $zero, 128             
draw_rect_loop: beq $t0, $t1, Return5
# draw line     
                add $t3, $zero, $zero
                add $t7, $zero, $a3
draw_line: beq $t3, $t4, end_draw_line # draw full row
           addi $t6, $zero, 1
           lw $t5, 0($t7)
check_bit: beq $t5, $t6, coloring
           sw $a2 0($a0)
           j else 
coloring: sw $a1, 0($a0) # draw at address
else: addi $a0, $a0, 4 # increment draw location
      addi $t7, $t7, 4 # increment log array
      addi $t3, $t3, 4 # increment loop variable
      j draw_line
      
end_draw_line: addi $t0, $t0, 1
               j draw_rect_loop
Return5: jr $ra

######################################################################################################################

draw_buffer: add $t5, $zero, $zero # initailize loop variable
             addi $t9, $zero, 4096 # set rectangle size
             lw $a0, displayAddress
             la $t0, buffer
start7: beq $t5, $t9, Return7 # exit once finished drawing
       lw $t1, 0($t0)
       sw $t1 0($a0) # color area 
       addi $a0, $a0, 4 #increment pixel
       addi $t0, $t0, 4
update7: addi $t5, $t5, 4 #increment loop variable
	j start7
Return7: jr $ra

######################################################################################################################
collision_detection: lw $t0, frog_y
                     lw $t2, frog_x
                     beq $t0, 3072, vbottom
                     beq $t0, 2560, vtop
                     beq $t0, 1536, lbottom
                     beq $t0, 1024, ltop
                     j Return8 # no collision
vbottom: la $t1, bottom_vehicles # load bottom vehicles array
         add $t1, $t1, $t2 # shift object array to coreesponding location
         j checking1 # check for collision at this location
vtop: la $t1, top_vehicles # load top vehicles array
         add $t1, $t1, $t2 # shift object array to coreesponding location
         j checking1 # check for collision at this location


ltop: la $t1, top_logs # load top vehicles array
         add $t1, $t1, $t2 # shift object array to coreesponding location
         add $a0, $zero, $zero # set direction indicator
         j checking2 # check for collision at this location


lbottom: la $t1, bottom_logs # load top vehicles arra
         add $t1, $t1, $t2 # shift object array to coreesponding location
         addi $a0, $zero, 1 # set direction indicator
         j checking2 # check for collision at this location
 
         
checking1: addi $t3, $zero, 4
           add $t5, $zero, $zero 
loop_check1: beq $t3, $t5, Return8
             lw $t6, 0($t1)
             beq $t6, 1, collision # if correspoding position in bit array holds 1, we have collision
update1: addi $t5, $t5, 1
         addi $t1, $t1, 4
         j loop_check1
         
checking2: addi $t3, $zero, 4
           add $t5, $zero, $zero 
loop_check2: beq $t3, $t5, respond_to_log
             lw $t6, 0($t1)
             beq $t6, 0, collision # if correspoding position in bit array holds 0, we have collision
update2: addi $t5, $t5, 1
         addi $t1, $t1, 4
         j loop_check2
         j Return8
collision: addi $s0, $zero, 1 # denote collision
    # play sound
    li $v0, 31   
    li $a0, 61
    li $a1, 500
    li $a2, 121
    li $a3, 90
    syscall
           j collision_acountability
Return8: jr $ra

###########################################################################################################################
respond_to_log:  addi $s2, $zero, 1
                 j on_log
                 j Return8


###########################################################################################################################
check_success:
la $t0, frog_y
lw $t1, 0($t0) 
bne $t1, 0, check_frog2 # branch if frog not in a success zone

la $t1, frog_x
lw $t3, 0($t1)
addi $t2, $zero, 16
div $t3, $t2
mfhi $t4
bne $t4, $zero, check_frog2 # branch if frog is not flush with a success zone 

mflo $t4
addi $t0, $zero, 4
mult $t4, $t0
mflo $t4
la $t0, success
add $t0, $t0, $t4 # corresponding position in success array
lw $t1, 0($t0) # indicator bit 
bne $t1, $zero, check_frog2 # branch if frog has been here before already
addi $t1, $t1, 1
sw $t1, 0($t0) # indicate that this zone has been succesfully reached
la $t0, points
lw $t1, 0($t0)
addi $t1, $t1, 1
sw $t1, 0($t0) #increment points
addi $s1, $zero, 1 # indciate success
    # play sound
    li $v0, 31   
    li $a0, 72
    li $a1, 1000
    li $a2, 122
    li $a3, 110
    syscall

check_frog2:
la $t0, bfrog_y
lw $t1, 0($t0) 
bne $t1, 0, no_success # branch if frog not in a success zone

la $t1, bfrog_x
lw $t3, 0($t1)
addi $t2, $zero, 16
div $t3, $t2
mfhi $t4
bne $t4, $zero, no_success # branch if frog is not flush with a success zone 

mflo $t4
addi $t0, $zero, 4
mult $t4, $t0
mflo $t4
la $t0, success
add $t0, $t0, $t4 # corresponding position in success array
lw $t1, 0($t0) # indicator bit 
bne $t1, $zero, no_success # branch if frog has been here before already
addi $t1, $t1, 1
sw $t1, 0($t0) # indicate that this zone has been succesfully reached
la $t0, points
lw $t1, 0($t0)
addi $t1, $t1, 1
sw $t1, 0($t0) #increment points
addi $s1, $zero, 1 # indciate success
no_success: jr $ra # make no changes if the frog is not in a unfilled success zone

######################################################################################################################
draw_success: add $t0, $zero, $zero # initialize loop variable i
              addi $t1, $zero, 4 # height of success zone
              la $t4, success # success loop indicator 
              addi $t5, $zero, 128
              la $t3, buffer # start of drawing zone
              li $t9, 0x953553
draw_srect_loop: beq $t0, $t1, done_drawing # success regions filled
                 add $t6, $zero, $zero # inner loop variable
draw_sline: beq $t6, $t5, end_draw_sline # drawn one complete line
            addi $t8, $zero, 16 
            div $t6, $t8 # find index corresponding to pixel in success array floor(pizel/16)
            mflo $t7 # store it here
            addi $t8, $zero, 4 
            mult $t7, $t8 # multiply it by 4 to get actual address increment
            mflo $t7 # actual increment
            add $t8, $t4, $t7 # find indicator bit address
            lw $t7, 0($t8) # load bit
check_sbit: beq $t7, 1, scoloring
            j selse 
scoloring: sw $t9, 0($t3) # draw at address
selse: addi $t3, $t3, 4 # increment draw location
       addi $t6, $t6, 4 # increment loop variable
       j draw_sline           
end_draw_sline: addi $t0, $t0, 1
                j draw_srect_loop
done_drawing: jr $ra

######################################################################################################################
draw_numbers: add $t0, $zero, $a0 # load drawing address
              add $t1, $zero, $a1 # load number to be drawn
              add $t2, $zero, $a2 # load color
              beq $t1, 0, draw_0
              beq $t1, 1, draw_1
              beq $t1, 2, draw_2
              beq $t1, 3, draw_3
              beq $t1, 4, draw_4
              beq $t1, 5, draw_5
              beq $t1, 6, draw_6
              beq $t1, 7, draw_7
              beq $t1, 8, draw_8
              j points_on_the_board
              
draw_0: sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0) # top line drawn
        addi $t0, $a0, 128 # move to second line
        sw $t2, 0($t0)
        addi $t0, $t0, 8
        sw $t2, 0($t0) # second line drawn
        addi $t0, $a0, 256 # move to third line
        sw $t2, 0($t0)
        addi $t0, $t0, 8
        sw $t2, 0($t0) # third line drawn  
        addi $t0, $a0, 384 # move to fourth line
        sw $t2, 0($t0)
        addi $t0, $t0, 8
        sw $t2, 0($t0) # fourth line line drawn
        addi $t0, $a0, 512 # move to fifth line
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0) # fifth line draw
        j points_on_the_board
draw_1: add $t0, $zero, $a0 # start at first line
        addi $t0, $t0, 4
        sw $t2, 0($t0) 
        addi $t0, $t0, 4
	sw $t2, 0($t0) 
        addi $t0, $a0, 128 # move to second line
        addi $t0, $t0, 4
	sw $t2, 0($t0) 
        addi $t0, $a0, 256 # move to third line
        addi $t0, $t0, 4
	sw $t2, 0($t0) 
        addi $t0, $a0, 384 # move to fourth line
        addi $t0, $t0, 4
	sw $t2, 0($t0) 
        addi $t0, $a0, 512 # move to fifth line
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0) # fifth line draw
        j points_on_the_board
draw_2: add $t0, $zero, $a0 # start at first line
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0)
        addi $t0, $a0, 128 # move to second line
        addi $t0, $t0, 8
        sw $t2, 0($t0)
        addi $t0, $a0, 256 # move to third line
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0)
        addi $t0, $a0, 384 # move to fourth line
        sw $t2, 0($t0)
        addi $t0, $a0, 512 # move to fifth line
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0) # fifth line draw
        j points_on_the_board

draw_3: add $t0, $zero, $a0 # start at first line
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0) 
        addi $t0, $a0, 128 # move to second line
        addi $t0, $t0, 8
        sw $t2, 0($t0) 
        addi $t0, $a0, 256 # move to third line
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0) 
        addi $t0, $a0, 384 # move to fourth line
        addi $t0, $t0, 8
        sw $t2, 0($t0) 
        addi $t0, $a0, 512 # move to fifth line
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0) # fifth line draw
        j points_on_the_board

draw_4: add $t0, $zero, $a0 # start at first line
        sw $t2, 0($t0)
        addi $t0, $t0, 8
        sw $t2, 0($t0)
        addi $t0, $a0, 128 # move to second line
        sw $t2, 0($t0)
        addi $t0, $t0, 8
        sw $t2, 0($t0)
        addi $t0, $a0, 256 # move to third line
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0) 
        addi $t0, $a0, 384 # move to fourth line
        addi $t0, $t0, 8
        sw $t2, 0($t0)
        addi $t0, $a0, 512 # move to fifth line
        addi $t0, $t0, 8
        sw $t2, 0($t0)
        j points_on_the_board

draw_5: add $t0, $zero, $a0 # start at first line
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0) 
        addi $t0, $a0, 128 # move to second line
        sw $t2, 0($t0) 
        addi $t0, $a0, 256 # move to third line
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0) 
        addi $t0, $a0, 384 # move to fourth line
        addi $t0, $t0, 8
        sw $t2, 0($t0) 
        addi $t0, $a0, 512 # move to fifth line
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0) # fifth line draw
        j points_on_the_board
draw_6: add $t0, $zero, $a0 # start at first line
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0) 
        addi $t0, $a0, 128 # move to second line
        sw $t2, 0($t0) 
        addi $t0, $a0, 256 # move to third line
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0) 
        addi $t0, $a0, 384 # move to fourth line
        sw $t2, 0($t0)
        addi $t0, $t0, 8
        sw $t2, 0($t0)         
        addi $t0, $a0, 512 # move to fifth line
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0) # fifth line draw
        j points_on_the_board
draw_7: add $t0, $zero, $a0 # start at first line
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0)
        addi $t0, $a0, 128 # move to second line
        addi $t0, $t0, 8
        sw $t2, 0($t0)
        addi $t0, $a0, 256 # move to third line
        addi $t0, $t0, 8
        sw $t2, 0($t0)
        addi $t0, $a0, 384 # move to fourth line
        addi $t0, $t0, 8
        sw $t2, 0($t0)
        addi $t0, $a0, 512 # move to fifth line
        addi $t0, $t0, 8
        sw $t2, 0($t0)
        j points_on_the_board
draw_8: add $t0, $zero, $a0 # start at first line
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0) 
        addi $t0, $a0, 128 # move to second line
        sw $t2, 0($t0) 
        addi $t0, $t0, 8
        sw $t2, 0($t0)         
        addi $t0, $a0, 256 # move to third line
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0) 
        addi $t0, $a0, 384 # move to fourth line
        sw $t2, 0($t0) 
        addi $t0, $t0, 8
        sw $t2, 0($t0) 
        addi $t0, $a0, 512 # move to fifth line
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0)
        addi $t0, $t0, 4
        sw $t2, 0($t0) # fifth line draw
        j points_on_the_board          
        
points_on_the_board: jr $ra # drawing finished

######################################################################################################################
bcollision_detection: lw $t0, bfrog_y
                     lw $t2, bfrog_x
                     beq $t0, 3072, bvbottom
                     beq $t0, 2560, bvtop
                     beq $t0, 1536, blbottom
                     beq $t0, 1024, bltop
                     j bReturn8 # no collision
bvbottom: la $t1, bottom_vehicles # load bottom vehicles array
         add $t1, $t1, $t2 # shift object array to coreesponding location
         j bchecking1 # check for collision at this location
bvtop: la $t1, top_vehicles # load top vehicles array
         add $t1, $t1, $t2 # shift object array to coreesponding location
         j bchecking1 # check for collision at this location


bltop: la $t1, top_logs # load top vehicles array
         add $t1, $t1, $t2 # shift object array to coreesponding location
         add $a0, $zero, $zero # set direction indicator
         j bchecking2 # check for collision at this location


blbottom: la $t1, bottom_logs # load top vehicles array
         add $t1, $t1, $t2 # shift object array to coreesponding location
         addi $a0, $zero, 1 # set direction indicator
         j bchecking2 # check for collision at this location
 
         
bchecking1: addi $t3, $zero, 4
           add $t5, $zero, $zero 
bloop_check1: beq $t3, $t5, bReturn8
             lw $t6, 0($t1)
             beq $t6, 1, bcollision # if correspoding position in bit array holds 1, we have collision
bupdate1: addi $t5, $t5, 1
         addi $t1, $t1, 4
         j bloop_check1
         
bchecking2: addi $t3, $zero, 4
           add $t5, $zero, $zero 
bloop_check2: beq $t3, $t5, brespond_to_log
             lw $t6, 0($t1)
             beq $t6, 0, bcollision # if correspoding position in bit array holds 0, we have collision
bupdate2: addi $t5, $t5, 1
         addi $t1, $t1, 4
         j bloop_check2
         j bReturn8
bcollision: addi $s0, $zero, 1 # denote collision
            # play sound
    li $v0, 31   
    li $a0, 61
    li $a1, 500
    li $a2, 121
    li $a3, 90
    syscall
    j collision_acountability
bReturn8: jr $ra

###########################################################################################################################
brespond_to_log: addi $s3, $zero, 1
                 j on_log1
                 j bReturn8


###########################################################################################################################
draw_press_q: add $t0, $zero, $a0 # load first line start address
              li $t1, 0xffffff # load color
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0) # P
              addi $t0, $t0, 8
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0) # R
              addi $t0, $t0, 8
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0) # E
              addi $t0, $t0, 8
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0) # S
              addi $t0, $t0, 8
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0) # S
              addi $t0, $t0, 16
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0) # q
              addi $t0, $a0, 128 # load second line start address
              sw $t1, 0($t0)
              addi $t0, $t0, 8
              sw $t1, 0($t0)
              addi $t0, $t0, 8
              sw $t1, 0($t0)
              addi $t0, $t0, 8
              sw $t1, 0($t0)
              addi $t0, $t0, 8
              sw $t1, 0($t0)
              addi $t0, $t0, 16
              sw $t1, 0($t0)
              addi $t0, $t0, 16
              sw $t1, 0($t0)
              addi $t0, $t0, 24
              sw $t1, 0($t0)
              addi $t0, $t0, 8
              sw $t1, 0($t0)
              addi $t0, $a0, 256 # load third line start address
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0) # P
              addi $t0, $t0, 8
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0) # R
              addi $t0, $t0, 8
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0) # E
              addi $t0, $t0, 8
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0) # S
              addi $t0, $t0, 8
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0) # S
              addi $t0, $t0, 16
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 8
              sw $t1, 0($t0) 
              addi $t0, $a0, 384 # load fourth line start address
              sw $t1, 0($t0) 
              addi $t0, $t0, 16
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 12
              sw $t1, 0($t0)
              addi $t0, $t0, 24
              sw $t1, 0($t0)
              addi $t0, $t0, 16
              sw $t1, 0($t0)
              addi $t0, $t0, 24
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $a0, 512 # load fifth line start address
              sw $t1, 0($t0)
              addi $t0, $t0, 16
              sw $t1, 0($t0)
              addi $t0, $t0, 8
              sw $t1, 0($t0)
              addi $t0, $t0, 8
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 8
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 8
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 24
              sw $t1, 0($t0)
              jr $ra
draw_retry: add $t0, $zero, $a0 # load first line start address
            li $t1, 0xffffff # load color
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0) # P
              addi $t0, $t0, 8
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0) # R
              addi $t0, $t0, 8
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0) # E
              addi $t0, $t0, 8
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0) # S
              addi $t0, $t0, 8
              sw $t1, 0($t0) 
              addi $t0, $t0, 8
              sw $t1, 0($t0) 
              addi $t0, $t0, 8
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $a0, 128 # load second line start address
              sw $t1, 0($t0)
              addi $t0, $t0, 8
              sw $t1, 0($t0)
              addi $t0, $t0, 8
              sw $t1, 0($t0)
              addi $t0, $t0, 20
              sw $t1, 0($t0)
              addi $t0, $t0, 12
              sw $t1, 0($t0)
              addi $t0, $t0, 8
              sw $t1, 0($t0)
              addi $t0, $t0, 12
              sw $t1, 0($t0)
              addi $t0, $t0, 12
              sw $t1, 0($t0)
              addi $t0, $t0, 8
              sw $t1, 0($t0)
              addi $t0, $a0, 256 # load third line start address
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0) # P
              addi $t0, $t0, 8
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0) # R
              addi $t0, $t0, 12
              sw $t1, 0($t0) 
              addi $t0, $t0, 12
              sw $t1, 0($t0) 
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0) 
              addi $t0, $t0, 12
              sw $t1, 0($t0) 
              addi $t0, $t0, 20
              sw $t1, 0($t0) 
              addi $t0, $a0, 384 # load fourth line start address
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0) 
              addi $t0, $t0, 12
              sw $t1, 0($t0)
              addi $t0, $t0, 20
              sw $t1, 0($t0) 
              addi $t0, $t0, 12
              sw $t1, 0($t0) 
              addi $t0, $t0, 4
              sw $t1, 0($t0) 
              addi $t0, $t0, 16
              sw $t1, 0($t0) 
              addi $t0, $t0, 16
              sw $t1, 0($t0) 
              addi $t0, $a0, 512 # load fifth line start address
              sw $t1, 0($t0) 
              addi $t0, $t0, 8
              sw $t1, 0($t0) 
              addi $t0, $t0, 8
              sw $t1, 0($t0) 
              addi $t0, $t0, 4
              sw $t1, 0($t0) 
              addi $t0, $t0, 4
              sw $t1, 0($t0) 
              addi $t0, $t0, 12
              sw $t1, 0($t0) 
              addi $t0, $t0, 12
              sw $t1, 0($t0) 
              addi $t0, $t0, 8
              sw $t1, 0($t0) 
              addi $t0, $t0, 12
              sw $t1, 0($t0) 
              addi $t0, $t0, 16
              sw $t1, 0($t0) 
              jr $ra
              
draw_restart: add $t0, $zero, $a0 # load first line start address
              li $t1, 0xffffff # load color
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0) 
              addi $t0, $t0, 8
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0) 
              addi $t0, $t0, 8
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0) 
              addi $t0, $t0, 8
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0)
              addi $t0, $t0, 4
              sw $t1, 0($t0) 
              addi $t0, $t0, 12
              sw $t1, 0($t0) 
              addi $t0, $t0, 12
              sw $t1, 0($t0) 
              addi $t0, $t0, 4
              sw $t1, 0($t0) 
              addi $t0, $t0, 4
              sw $t1, 0($t0) 
              addi $t0, $t0, 8
              sw $t1, 0($t0) 
              addi $t0, $t0, 4
              sw $t1, 0($t0) 
              addi $t0, $t0, 4
              sw $t1, 0($t0) 
              addi $t0, $a0, 128 # load second line start address
              sw $t1, 0($t0) 
              addi $t0, $t0, 8
              sw $t1, 0($t0) 
              addi $t0, $t0, 8
              sw $t1, 0($t0) 
              addi $t0, $t0, 16
              sw $t1, 0($t0) 
              addi $t0, $t0, 20
              sw $t1, 0($t0) 
              addi $t0, $t0, 12
              sw $t1, 0($t0) 
              addi $t0, $t0, 8
              sw $t1, 0($t0) 
              addi $t0, $t0, 8
              sw $t1, 0($t0) 
              addi $t0, $t0, 8
              sw $t1, 0($t0) 
              addi $t0, $t0, 12
              sw $t1, 0($t0) 
              addi $t0, $a0, 256 # load third line start address
              sw $t1, 0($t0) 
              addi $t0, $t0, 4
              sw $t1, 0($t0) 
              addi $t0, $t0, 4
              sw $t1, 0($t0) 
              addi $t0, $t0, 8
              sw $t1, 0($t0) 
              addi $t0, $t0, 4
              sw $t1, 0($t0) 
              addi $t0, $t0, 4
              sw $t1, 0($t0) 
              addi $t0, $t0, 8
              sw $t1, 0($t0) 
              addi $t0, $t0, 4
              sw $t1, 0($t0) 
              addi $t0, $t0, 4
              sw $t1, 0($t0) 
              addi $t0, $t0, 12
              sw $t1, 0($t0) 
              addi $t0, $t0, 12
              sw $t1, 0($t0) 
              addi $t0, $t0, 4
              sw $t1, 0($t0) 
              addi $t0, $t0, 4
              sw $t1, 0($t0) 
              addi $t0, $t0, 8
              sw $t1, 0($t0) 
              addi $t0, $t0, 4
              sw $t1, 0($t0) 
              addi $t0, $t0, 4
              sw $t1, 0($t0) 
              addi $t0, $t0, 12
              sw $t1, 0($t0) 
              addi $t0, $a0, 384 # load fourth line start address
              sw $t1, 0($t0) 
              addi $t0, $t0, 4
              sw $t1, 0($t0) 
              addi $t0, $t0, 12
              sw $t1, 0($t0) 
              addi $t0, $t0, 24
              sw $t1, 0($t0) 
              addi $t0, $t0, 12
              sw $t1, 0($t0) 
              addi $t0, $t0, 12
              sw $t1, 0($t0) 
              addi $t0, $t0, 8
              sw $t1, 0($t0) 
              addi $t0, $t0, 8
              sw $t1, 0($t0) 
              addi $t0, $t0, 4
              sw $t1, 0($t0) 
              addi $t0, $t0, 16
              sw $t1, 0($t0) 
              addi $t0, $a0, 512 # load fifth line start address
              sw $t1, 0($t0) 
              addi $t0, $t0, 8
              sw $t1, 0($t0) 
              addi $t0, $t0, 8
              sw $t1, 0($t0) 
              addi $t0, $t0, 4
              sw $t1, 0($t0) 
              addi $t0, $t0, 4
              sw $t1, 0($t0) 
              addi $t0, $t0, 8
              sw $t1, 0($t0) 
              addi $t0, $t0, 4
              sw $t1, 0($t0) 
              addi $t0, $t0, 4
              sw $t1, 0($t0) 
              addi $t0, $t0, 12
              sw $t1, 0($t0) 
              addi $t0, $t0, 12
              sw $t1, 0($t0) 
              addi $t0, $t0, 8
              sw $t1, 0($t0) 
              addi $t0, $t0, 8
              sw $t1, 0($t0) 
              addi $t0, $t0, 8
              sw $t1, 0($t0) 
              addi $t0, $t0, 12
              sw $t1, 0($t0) 
              jr $ra
######################################################################################################################
on_log1: lw $t0, speed
         bne $t0, 0, slide1

move_frog_b1: bne $s3, 1, slide1 # check if frog  on log
lw $t0, bfrog_y # load frog y value
beq $t0, 1536, lower_logs_b1

la $t0, bfrog_x # load frog coords
lw $t3, 0($t0) # t3 x coord
addi $t5, $zero, 112
beq $t3, $t5, slide1
addi $t3, $t3, 4
sw $t3, 0($t0)
j slide1

lower_logs_b1:
la $t0, bfrog_x # load frog coords
lw $t3, 0($t0) # t3 x coord
addi $t5, $zero, 0
beq $t3, $t5, slide1
addi $t3, $t3, -4
sw $t3, 0($t0)

slide1: j bReturn8
######################################################################################################################
on_log:  lw $t0, speed
         bne $t0, 0, slide
# increment frog
bne $s2, 1, slide # check if frog on log
lw $t0, frog_y # load frog y value
beq $t0, 1536, lower_logs_a

la $t0, frog_x # load frog coords
lw $t3, 0($t0) # t3 x coord
addi $t5, $zero, 112
beq $t3, $t5, slide
addi $t3, $t3, 4
sw $t3, 0($t0)
j slide

lower_logs_a:
la $t0, frog_x # load frog coords
lw $t3, 0($t0) # t3 x coord
addi $t5, $zero, 0
beq $t3, $t5, slide
addi $t3, $t3, -4
sw $t3, 0($t0)

slide: j Return8

#####################################################################################################################
movement_sound:
    # play sound
    li $v0, 31   
    li $a0, 61
    li $a1, 500
    li $a2, 126
    li $a3, 60
    syscall
    jr $ra
#####################################################################################################################

              
              
              
              
              
               
