class String
#possible background for text
    def bg_black;       "\e[40m#{self}\e[0m" end
    def bg_red;         "\e[41m#{self}\e[0m" end
    def bg_green;       "\e[42m#{self}\e[0m" end
    def bg_brown;       "\e[43m#{self}\e[0m" end
    def bg_blue;        "\e[44m#{self}\e[0m" end
    def bg_magenta;     "\e[45m#{self}\e[0m" end
    def bg_cyan;        "\e[46m#{self}\e[0m" end
    def bg_gray;        "\e[47m#{self}\e[0m" end
#red font for results
    def red;            "\e[31m#{self}\e[0m" end
end

#class representing a single peg with a number (id) and a color
class Peg
    attr_reader :id

    def initialize(id)
        @id = id
    end

    #printing out a single peg
    def display
        #adding margins to make the code look nice and readable
        output = "   #{@id.to_s}   "
        #color depends on the id
        case @id
        when 1 
            print output.bg_magenta
        when 2
            print output.bg_cyan
        when 3 
            print output.bg_green
        when 4 
            print output.bg_gray
        when 5 
            print output.bg_brown
        when 6 
            print output.bg_blue
        end
    end
end

#class representing a combination of 4 pegs (the code oir a guess)
class Combination
    attr_reader :id_list, :combination

    #turning a 4-digit array into a combintaion of pegs
    def initialize(code)
        @combination = []
        @id_list = code
        (0..3).each do |index|
            new_peg = Peg.new(code[index])
            @combination.push new_peg
        end
        @combination
    end

    #printing out four pegs in a nice-looking line
    def display
        @combination.each do |peg|
            peg.display
        end
    end
end

class HumanPlayer
    attr_reader :name

    def initialize
        print "Enter your name: "
        @name = gets.chomp
    end

    #creating a guess-combination from the input 
    def create_code
        puts "Create a four-digit code for the computer to crack!"
        guess()
    end

    def guess; 
        begin
            input_comb = gets.chomp.split("")
            #checking the input for errors
            if input_comb.length != 4
                raise
            end
            input_comb.map! do |digit| 
                digit = digit.to_i
                if digit < 1 or digit > 6
                    raise
                end
                digit.to_i
            end
        rescue 
            puts "Input error detected. Enter 4 digits from 1 to 6, please!"
            retry
        end
        Combination.new(input_comb)
    end
end

class ComputerPlayer 
    attr_reader :name

    def initialize
        @name = "PC"
        @untried = []
    end
    
    #creates random code to start the game
    def create_code
        random_code = []
        (0..3).each do |index|
            #returns a random digit from 1 to 6
            new_peg_id = rand(6)+1
            random_code.push new_peg_id
        end
        Combination.new(random_code)
    end

    def guess(previous_guess, previous_result, current_game)
        #The PC uses Donald Knuth's method to solve the codebreaking game
        if @untried == []
            #for the very first guess - initializing the array of all possible options 
            create_array()
            return Combination.new([1,1,2,2])
        end
        #delete the options, that would not give the same response 
        #if the current guess was the code, from the "untried" list
        @untried.map do |comb|
            comb_check = current_game.check(comb, previous_guess)
            if comb_check != previous_result
                @untried.delete(comb)
            end
        end
        lowest_score = Float::INFINITY 
        best_next_guess = nil
        #iterating over all the untried possible guesses
        @untried.each do |possible_guess|
            #for each guess create a hash 
            possible_results = Hash.new(0)
            #iterating over all the untried combinations AGAIN - for each guess the result...
            #of comparing it with each possible code is determines and added to the hash
            @untried.each do |possible_code|
                possible_result = current_game.check(possible_code, possible_guess)
                possible_results[possible_result] += 1
            end
            #after the hash is completed we determine the most popular result
            most_common_result = possible_results.max_by {|k,v| v}
            #compare the most common result's score to the lowest score we saw at all. 
            #if current score is lower than the lowest score - current guess becomes the best for the next turn

            if most_common_result[1] < lowest_score
                lowest_score = most_common_result[1]
                best_next_guess = possible_guess
            end
        end
        #the guess with the lowest most commmon result's score
        best_next_guess
    end

    private
    def create_array
        (1..6).each do |a|
            (1..6).each do |b|
                (1..6).each do |c|
                    (1..6).each do |d|
                        @untried.push Combination.new([a,b,c,d])
                    end
                end
            end
        end
    end
end

class Game
    #compares the guess and the code
    def check(code, guess)
        #results represented as a hash {perfect:_, includes:_}
        result = Hash.new(0)
        #We create local copies of the code and a guess not to damage the originals
        code_unchecked = code.id_list.dup
        guess_unchecked = guess.id_list.dup
        #first we only check the guess for the exact natches
        guess_unchecked.each_with_index do |guess_peg, index|
            if guess_peg == code_unchecked[index]
                result["perfect"] += 1
                #If we find a "perfect" match we don't want to count it as "included" too
                code_unchecked[index] = nil
                guess_unchecked[index] = nil
            end
        end
        #Then we look for included but not perfect matches
        guess_unchecked.each do |guess_peg|
            if guess_peg != nil and code_unchecked.include?(guess_peg)
                result["includes"] += 1
                #Only counting one "included peg for each digit in guess"
                code_unchecked[code_unchecked.index(guess_peg)] = nil
            end
        end
        result
    end

    def print_result(result)
        print " | ".red
        (1..result["perfect"]).each {print "●".red}
        (1..result["includes"]).each {print "○".red}
        puts
    end

    def playgame(guesser, creator)
        puts "Our game begins! #{creator.name} created a code and #{guesser.name} needs to crack it. Good luck!"
        code = creator.create_code
        result = Hash.new(0)
        #Game lasts for 12 rounds
        previous_guess=nil
        (1..12).each do |round|
            puts "Round #{round}/12. Enter your guess:"
            #get input of player's guess
            guess = guesser.guess(previous_guess, result, self)
            guess.display
            #Check the code and the guess for matches
            result = check(code, guess)
            print_result(result)
            if result["perfect"] == 4
                puts "Congratulations!"
                puts "The code was guessed correctly in just #{round} attempts!"
                return nil
            end
            previous_guess = guess
        end
        puts "Sorry, #{guesser.name}, you ran out of tries.#{creator.name} Won! Here is the correct code:"
        code.display
    end
end

#Initializing a new game!
mastermind = Game.new
pc = ComputerPlayer.new
player = HumanPlayer.new
puts "Welcome to the Mastermind game!"

while 1
    puts "Would you like to guess the code or to make one for computer to solve?"
    puts 'Type "g" to play as code guesser, "c" to play as code creater or any other key to exit'
    key = gets.chomp.upcase
    if key == "G"
        #PC creates a random code
        mastermind.playgame(player, pc)
    elsif key == "C"
        #PC tries to guess the player's code
        mastermind.playgame(pc, player)
    else
        break
    end
    puts "\nWould you like to play again? Type \"y\" to restart: "
    if gets.chomp.upcase != "Y"
        break
    end
end
puts "Come play more later! Bye!"