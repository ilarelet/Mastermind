class HumanPlayer
    attr_reader :name

    def initialize
        print "Enter your name: "
        @name = gets.chomp
    end

    #creating a guess-combination from the input 
    def create_code
        puts "Create a four-digit code for the computer to crack!"
        guess(nil, nil, nil)
    end

    def guess(previous_guess, previous_result, current_game); #for future revision!
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