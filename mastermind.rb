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
    attr_reader :name

    def initialize
        @name = "PC"
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
end

class Game
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

    def print_result(result)
        print " | ".red
        (1..result["perfect"]).each {print "●".red}
        (1..result["includes"]).each {print "○".red}
        puts
    end

    def playgame(guesser, creator, code)
        puts "Our game begins! #{creator.name} created a code and #{guesser.name} need to crack it. Good luck!"
        #Game lasts for 12 rounds
        (1..12).each do |round|
            puts "Round #{round}/12. Enter your guess:"
            #get input of player's guess
            guess = guesser.guess
            guess.display
            #Check the code and the guess for matches
            result = check(code, guess)
            print_result(result)
            if result["perfect"] == 4
                puts "Congratulations!"
                puts "You've guessed the code correctly in just #{round} attempts!"
                return nil
            end
        end
        puts "Sorry, you ran out of tries. Here is the correct code:"
        code.display
    end
end

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
        code = pc.create_code
        mastermind.playgame(player, pc, code)
    elsif key == "C"
        #PC tries to guess the player's code
        code = pc.create_code
        mastermind.playgame(pc, player, code)
    else
        break
    end
    puts "\nWould you like to play again? Type \"y\" to restart: "
    if gets.chomp.upcase != "Y"
        break
    end
end
puts "Come play more later! Bye!"