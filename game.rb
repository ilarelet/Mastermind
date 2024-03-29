class Game
    attr_reader :previous_guess, :previous_result
    def playgame(guesser, creator)
        puts "Our game begins! #{creator.name} created a code and #{guesser.name} needs to crack it. Good luck!"
        code = creator.create_code
        result = Hash.new(0)
        #Game lasts for 12 rounds
        previous_guess=nil
        (1..12).each do |round|###################
            puts "Round #{round}/12. Enter your guess:"
            #get input of player's guess
            guess = guesser.guess(self)
            guess.display
            #Check the code and the guess for matches
            result = check(code, guess)
            print_result(result)
            if result["perfect"] == 4
                puts "Congratulations!"
                puts "The code was guessed correctly in just #{round} attempts!"
                return nil
            end
            @previous_guess = guess
            @previous_result = result
        end
        puts "Sorry, #{guesser.name}, you ran out of tries.#{creator.name} Won! Here is the correct code:"
        code.display
    end

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
end