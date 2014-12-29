# https://github.com/betweenparentheses/ruby-oop-projects/blob/master/mastermind.rb

module Mastermind

# a row represents six colors with letters A - F
class Row

# initialize blank code
  def initialize(code="")
    @code = code
  end

  def ==(other_thing)
    self.code == other_thing.code
  end

  def self=(code)
    @code = code
  end

  def [](index)
    @code[index]
  end

  def include?(value)
    @code.include?(value)
  end

  def count(letter)
    @code.count(letter)
  end
end


class Board

# empty array for guesses & responses
  def initialize
      @guesses = []
      @responses = []
  end

  def set_code(code)
    @code ||= code
  end

  def input_guess(row)
    @guesses << row
  end

  def input_response(row)
    @responses << row
  end

  def last_guess
    @guesses.last
  end

  def last_response
    @responses.last
  end

  def last_correct
    last_response.correct #breaks Demeter in a bad way. How do I fix this?
  end

  def last_wrong_place
    last_response.wrong_place
  end

  def this_turn
    @guesses.size + 1
  end

  def last_turn
    @guesses.size
  end

  def display
    if this_turn == 1
      puts "No guesses yet."
    else
#       loop from 1 to final turn
      (1..last_turn).each do |turn|
        print "Guess \##{turn}: "
        print @guesses[turn-1]
        print "   |  "
        print @responses[turn-1]
        puts "\n"
      end
    end
  end

end


class Response
  attr_reader :correct, :wrong_place
  def initialize(correct, wrong_place)
    @correct = correct
    @wrong_place = wrong_place
  end

  def to_s
    "#{@correct} correct, #{@wrong_place} right letter but wrong place."
  end

  def all_correct?
    @correct == 4
  end
end


class Player

  def respond(guess)
    @code_frequency = letters_count(@secret_code)
    @guess_frequency = letters_count(guess)

    correct = count_correct(guess)
    wrong_place = count_wrong_places(@code_frequency, @guess_frequency)

    Response.new(correct, wrong_place)
  end

private

  def letters_count(code)
    count = Hash.new(0)
    colors.each do |letter|
      count[letter] = code.count(letter)
    end
    count
  end

  def count_wrong_places(code_frequency, guess_frequency)
    wrong_place = 0
    colors.each do |letter|
      if code_frequency[letter] > 0 && guess_frequency[letter] >= code_frequency[letter]
        wrong_place += code_frequency[letter]
      elsif code_frequency[letter] > 0 && guess_frequency[letter] > 0 && guess_frequency[letter] < code_frequency_letter
        wrong_place += guess_frequency[letter]
      end
    end
    wrong_place
  end

  def count_correct(guess)
    correct = 0
    (0..3).each do |index|
      letter = guess[index]
      if @secret_code[index] == letter
        correct += 1
        @code_frequency[letter] -= 1
        @guess_frequency[letter] -= 1
      end
    end
    correct
  end

  def colors
    ["A", "B", "C", "D", "E", "F"]
  end
end

class AI < Player

  def initialize
    @letters = {}
    @all_possible_guesses = []
    colors.each do |first|
      colors.each do |second|
        colors.each do |third|
          colors.each do |fourth|
            @all_possible_guesses << "#{first}#{second}#{third}#{fourth}"
          end
        end
      end
    end
  end

  def devise_code
    code_string = ""
    4.times do
      letter = colors.sample
      code_string << letter
    end
    @secret_code = Row.new(code_string)
  end

#given a letter, and knowinr
  def remove_impossibles(letter, board)
    @letters[letter] = board.last_correct
    @all_possible_guesses.select! { |code| code.count(letter) == @letters[letter]}
  end

#This is a stupid algorithm that wins about half the time
#Guesses four of each letter to determine frequency of characters
#and then guesses randomly from the 16-or-fewer combinations that remain,
#removing any that didn't win.
  def guess(board)
    case board.this_turn
    when 1
      return "AAAA"
    when 2
      remove_impossibles("A", board)
      return "BBBB"
    when 3
      remove_impossibles("B", board)
      return "CCCC"
    when 4
      remove_impossibles("C", board)
      return "DDDD"
    when 5
      remove_impossibles("D", board)
      return "EEEE"
    when 6
      remove_impossibles("E", board)
      return "FFFF"
    when 7
      remove_impossibles("F", board)
      return @all_possible_guesses.sample
    else
      @all_possible_guesses.select! {|code| code != board.last_guess}
      return @all_possible_guesses.sample
    end
  end
end

class Human < Player
  #only takes board to match ducktype of the AI version
  def guess(board)
    print "Take a guess (4 letters A-F, can repeat): "
    gets.chomp.upcase
  end

  def devise_code
     print "What's the secret code this time (4 letters A-F, can repeat letters)? "
     code_string = gets.chomp.upcase
     until code_string.length == 4 do
       print "That doesn't seem right. Try again: "
       code_string = gets.chomp.upcase
     end
     @secret_code = Row.new(code_string)
  end

end



class Game
  attr_accessor :codemaker, :codebreaker, :score, :board

  def initialize
    @board = Board.new
    @score = 0
  end

  def start
    choose_sides
    get_code
    puts "The codemaker has just devised a secret code, 4 letters long, A-F. (Example: FBCA)."
    puts "Time to match wits against the machine!"
    12.times {take_turn}
    puts codebreaker.is_a?(Human) ? "Tragically, you have failed to break the code.":"Victory! The computer failed to outthink you!"

  end

  def choose_sides
    puts "Do you want to be the\nA) CODEMAKER \nor the \nB) CODEBREAKER?"
    print "(choose A or B): "
    answer = gets.chomp.upcase
    until answer == "A" || answer == "B"
     print "Try again. That's not an answer: "
     answer = gets.chomp.upcase
    end
    set_sides(answer)
  end

 def set_sides(answer)
   case answer
   when "A"
     @codemaker = Human.new
     @codebreaker = AI.new
   when "B"
     @codemaker = AI.new
     @codebreaker = Human.new
   end
 end

  def get_code
    codemaker.devise_code
  end

  def take_turn

    get_guess(codebreaker)
    get_response(codemaker)
    board.display
    if won? && codebreaker.is_a?(Human)
      puts "Congratulations! You guessed it on turn #{board.last_turn}."
      exit
    elsif won? && codebreaker.is_a?(AI)
      puts "Your clever code has been cracked on turn #{board.last_turn}."
      puts "Better luck next time!"
      exit
    end
    print "*** Press Enter For Next Turn ***"
    gets
  end

  def get_guess(codebreaker)
    guess = codebreaker.guess(board)
    input_guess(guess)
  end

  def get_response(codemaker)
    guess = board.last_guess
    response = codemaker.respond(guess)
    input_response(response)
  end

  def input_guess(guess)
    board.input_guess(guess)
  end

  def input_response(response)
    board.input_response(response)
  end

  def won?
    last_response = board.last_response
    last_response.all_correct?
  end
end

end

include Mastermind

g = Game.new
g.start