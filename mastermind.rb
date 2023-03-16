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