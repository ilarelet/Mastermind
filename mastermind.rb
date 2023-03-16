class ComputerPlayer 
    attr_reader :name

    def initialize
        @name = "PC"
        @unchecked = []
        @s = []
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
        if @unchecked == []
            #for the very first guess - initializing the array of all possible options 
            create_array()
            @s = @unchecked.dup
            #start with a basic combination 1-1-2-2
            return Combination.new([1,1,2,2])
        end
        puts "Let me think..."
        #delete the options, that would not give the same response 
        #if the current guess was the code, from the "s" array
        @s.each_with_index.map do |comb, index|
            @s[index] = nil if current_game.check(previous_guess, comb) != previous_result 
        end
        #Clean up the "s" array from the nils
        @s.compact!
        #starting a search for the guess with the lowest "score" - minmax function
        lowest_score = Float::INFINITY 
        best_next_guesses = []
        #iterating over all the untried possible guesses
        @unchecked.each do |possible_guess|
            #for each guess create a hash 
            possible_scores = Hash.new(0)
            #iterating over the "s" array to see how many codes would be deleted
            #if we choose the current possible_guess for the next turn
            @s.each do |possible_code|
                possible_result = current_game.check(possible_guess, possible_code)
                possible_scores[possible_result] += 1
            end
            #after the hash of possible score is completed we determine the result with the highest score
            highest_score_result = possible_scores.max_by {|k,v| v} [1]
            #compare the most common result's score to the lowest score we saw at all. 
            #if current score is lower than the lowest score - current guess becomes the best for the next turn
            if highest_score_result < lowest_score
                lowest_score = highest_score_result
                best_next_guesses = []
                best_next_guesses.push possible_guess
            elsif highest_score_result = lowest_score
                best_next_guesses.push possible_guess
            end
        end
        #Out of the possible next guesses with the lowest score we preferably choose one from 's'
        best_next_guesses.each do |guess| 
            if @s.include?(guess)
                @unchecked.delete(guess) 
                return guess
            end
        end
        #if none of the "best guesses" are in 's' we pick the first one 
        @unchecked.delete(best_next_guesses[0])
        best_next_guesses[0]
    end

    private
    def create_array
        (1..6).each do |a|
            (1..6).each do |b|
                (1..6).each do |c|
                    (1..6).each do |d|
                        @unchecked.push Combination.new([a,b,c,d])
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
        #result["perfect"] = guess_unchecked.count.with_index {|guess_peg, index| guess_peg == code_unchecked[index]}

        ###
        matches = []
        guess_unchecked.each_with_index do |guess_peg, index|
            if guess_peg == code_unchecked[index]
                result["perfect"] += 1
                #If we find a "perfect" match we don't want to count it as "included" too, so we keep it's index in "matches" array
                matches.push index
            end
        end
        #Then we look for included but not perfect matches
        guess_unchecked.each_with_index do |guess_peg, index|
            if !matches.include?(index)
                code_unchecked.each_with_index do |code_peg, index_code|
                    if !matches.include?(index_code) and guess_peg == code_peg
                        result["includes"] += 1
                        code_unchecked[index_code] = nil
                        break
                    end
                end
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
        (1..12).each do |round|###################
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
    pc = ComputerPlayer.new
end
puts "Come play more later! Bye!"