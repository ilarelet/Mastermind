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