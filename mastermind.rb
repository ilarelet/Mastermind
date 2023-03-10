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
        print "\n"
    end
end

class HumanPlayer
    #creating a guess-combination from the input 
    def guess
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

    #compares the guess and the code
    def check(code, guess)
        #results represented as a hash {perfect:_, includes:_}
        result = Hash.new(0)
        (0..3).each do |index|
            if guess.combination[index].id == code.combination[index].id
                result["perfect"] += 1
            elsif code.id_list.include?( guess.combination[index].id)
                result["includes"] += 1
            end
        end
        result
    end

    def playgame(player, code)
        #Game lasts for 12 rounds
        (1..12).each do |round|
            puts "Round #{round}/12: Enter your guess"
            #get input of player's guess
            guess = player.guess
            guess.display
            #Check the code and the guess for matches
            result = check(code, guess)
            puts result
            puts
            if result["perfect"] == 4
                puts "Congratulations!"
                puts "You've guessed the code correctly in just #{round} attempts!"
                return nil
            end
        end
        puts "Sorry, you ran out of tries. The correct code was #{code}"
    end
end

#players creation
player = HumanPlayer.new
pc = ComputerPlayer.new


while 1
    #PC creates a random code
    code = pc.create_code
    code.display
    pc.playgame(player, code)
    puts 'Would you like to play again? Type "y" to restart: ' 
    if gets.chomp.upcase != "Y"
        puts "Come play more later! Bye!"
        break
    end
end