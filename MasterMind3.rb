 # https://github.com/ArturJanik/oopproject2/blob/master/p2-mastermind.rb
 
 class Game
    attr_reader :guess_me, :round, :game_board, :result
    
#     initalize
    def initialize
#       new array of the answer
      @guess_me = Array.new
#       set round number to 1
      @round = 1
#       new array for the game board
      @game_board = Array.new
      
#       new array for the result
      @result = Array.new
      
#       4 times add a random number the guess me
      4.times { @guess_me << rand(6)+1 }
      
#       me printing naswer
      print guess_me  
      
#       print instructions
      init_instructions
    end
    
    #########################
    # Method that runs whole gameplay for number of round chosen by player
    def game_round
      
#       only does 12 turns
      while @round<13
        puts "\nRound #{round}"
        puts "================="
        puts "Enter 4 digits (between 1 and 6 each):"
        
#         puts the chars user enters into a new map & makes it into integer form?
        player_guess = gets.chomp.chars.map(&:to_i)
        
#        push the player guess into the gameboard
        game_board << player_guess
        
#         use the player guess to check the guess
        check_guess(player_guess)
        
#         call show results
        show_results
        
#         increment round number
        @round = @round + 1
      end
      
#       if loop was completed reach this point
      puts "\nYOU LOSE! Sorry :)"
      
#       display answer
      puts "\nThe correct answer was #{guess_me}"
    end
    #########################
    
    #########################
    # Method which prints out current results stored in game_board array
    def show_results

#       loop based on index & the x
      result.each_with_index do |x, i|
        
#         prints game board number & round number
        puts "#{game_board[i]} - #{x} - Round #{i+1}"
      end
    end
    #########################
    
    #########################
    # Method checking if player guess is correct
    def check_guess(player_guess)
      
#       if it completely matches, victory
      if player_guess == guess_me
        puts "\nCongratulations! You won!"
        exit
      else
#         if match not an exact match, call method below
        make_feedback(player_guess)
      end
    end
    #########################
    
    #########################
    # Method which creates feedback
    def make_feedback(player_guess)
      z = String.new
      gm_copy = [0,0,0,0]
      pg_copy = [0,0,0,0]
      
      
#       it looks like this is checking the user guess with the 
#       real code, each time it is exactly correct
#       "[ x ]"gets pushed to z array

      # First collect number of correct guesses to z array
      player_guess.each_with_index do |x, i|
        if x == guess_me[i]
          z << "[ x ]"
        else
          
#           i'm not sure what the point of this one is, maybe to use for method below?
#           maybe the part above removes the completely correct parts & below is to deal with
#           the rest?
          gm_copy[i] = guess_me[i]
          pg_copy[i] = x
        end
      end
      
#       i think it goes through pg_copy & its index as well

      # Next, check if any of left values exist in correct solution
      pg_copy.each_with_index do |x, i|
#         if gm_copy includes x, that means if the guess has any of the correct answers
        if x>0 && gm_copy.include?(x)
#           push it to the z array to be displayed
          z << "[ o ]"
          gm_copy[gm_copy.index(x)] = 0
          pg_copy[i] = 0
        end
      end
      
      result << z
      puts "\nResults until now:"
      result
    end
    #########################
    
    #########################
    # How to play instructions
    def init_instructions
      puts "\nWelcome to Mastermind task for The Odin Project."
      puts "\nHOW TO PLAY:"
      puts "Each round you will have to enter 4-digit number that consists of digits between 1 and 6."
      puts "For example: 1264 or 3452."
      puts "Each digit can appear multiple times, for example: 3335"
      puts "Every time you take a guess, you will see feedback like this one: "
      puts "[1, 2, 3, 4] - [ x ][ o ] - Round 1"
      puts "First array of 4 digits is your guess"
      puts "Second array of x'es and o's give you feedback. Each X means that one of your digits was correct and in correct place. Each O means that one of your digits was correct, but misplaced."
      puts "\nSo, do You want to take this challenge (Y/N)?"
      z = gets.chomp.downcase
      if z == "y" 
        puts "Let's play then!" 
      else 
        puts "Farewell!"
        exit
      end
    end
    #########################
    
  end

mastermind = Game.new
mastermind.game_round