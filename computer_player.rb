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

    def guess(current_game)
        previous_guess = current_game.previous_guess
        previous_result = current_game.previous_result
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