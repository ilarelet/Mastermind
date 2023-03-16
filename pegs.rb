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