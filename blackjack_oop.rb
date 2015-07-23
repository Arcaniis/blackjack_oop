module SystemClear

  def system_clear(player)
    system('cls')
    system('clear')
    puts "Your chips: $#{player.money}   Your bet: $#{player.bet}"
    puts ""
  end

end

module Common

  VALUE_TABLE = {'|2C|' => 2, '|3C|' => 3, '|4C|' => 4, '|5C|' => 5, '|6C|' => 6,
                '|7C|' => 7, '|8C|' => 8, '|9C|' => 9, '|10C|' => 10,
                '|JC|' => 10, '|QC|' => 10, '|KC|' => 10, '|AC|' => 11, '|2D|' => 2, 
                '|3D|' => 3, '|4D|' => 4, '|5D|' => 5, '|6D|' => 6, '|7D|' => 7, 
                '|8D|' => 8, '|9D|' => 9, '|10D|' => 10, '|JD|' => 10, '|QD|' => 10, 
                '|KD|' => 10, '|AD|' => 11, '|2S|' => 2, '|3S|' => 3, '|4S|' => 4, 
                '|5S|' => 5, '|6S|' => 6, '|7S|' => 7, '|8S|' => 8, '|9S|' => 9, 
                '|10S|' => 10, '|JS|' => 10, '|QS|' => 10, '|KS|' => 10, 
                '|AS|' => 11, '|2H|' => 2, '|3H|' => 3, '|4H|' => 4, '|5H|' => 5, 
                '|6H|' => 6, '|7H|' => 7, '|8H|' => 8, '|9H|' => 9, '|10H|' => 10, 
                '|JH|' => 10, '|QH|' => 10, '|KH|' => 10, '|AH|' => 11}

  def bust?(hand_value)
    if hand_value > 21
      true
    else
      false
    end
  end

  def hand_value(hand)
    value = 0
    hand.each do |card|
      value += VALUE_TABLE[card]
    end
    if value > 21
      hand.each do |card|
        if card =~ /\|A.\|/
          value -= 10
          if value < 22
            break
          end  
        end
      end
    end
    value
  end

  def blackjack?
    if self.hand_value(self.hand) == 21
      true
    else
      false
    end
  end

end

class Player
  include SystemClear
  include Common
  
  attr_accessor :money, :hand, :bet
  
  def initialize
    puts "=> Please enter how much money you will be changing to chips: (EX: $500 = '500')"
    puts "** Minimum bets are $20 **"
    @money = gets.chomp.to_i
    @hand = []
    @bet = 0
  end

  def place_bet
    while @bet < 20
      puts "Please place your bet for this hand:"
      puts "** Minimum bets are $20 **"
      @bet = gets.chomp.to_i
    end
  end

  def show_hidden(dealer, player)
      puts "Dealer shows: 'HIDDEN' / #{dealer.hand[1]}"
      puts ""
      puts "You have: #{player.hand_value(player.hand)} showing: #{player.hand.join(" ")}" 
      puts ""
  end

  def blackjack(dealer, player)
    player.show_hidden(dealer, player)
    puts "You hit BLACKJACK! You win!"
    player.money += (1.5 * player.bet)
    sleep(3.5)
    throw(:blackjack)
  end

  def take_turn(player, dealer)
    show_hidden(dealer, player)
    begin
      if player.hit?
        dealer.deal(player)
        system_clear(player)
        show_hidden(dealer, player)
      else
        break
      end
    end until player.bust?(player.hand_value(player.hand))
  end

  def hit?
    begin
      puts "Would you like to hit? (Y/N)"
      @answer = gets.chomp.downcase
    end until @answer == 'y' || @answer == 'n'
    if @answer == 'y'
      true
    else
      false
    end
  end

end

class Dealer
  include SystemClear
  include Common
  
  attr_reader :shoe
  attr_accessor :hand

  def initialize
    @shoe = Shoe.new(6).shoe.shuffle!
    @hand = []
  end

  def initial_deal(dealer, player)
    2.times do 
      card = @shoe.pop
      dealer.hand << card
    end
    2.times do
      card = @shoe.pop
      player.hand << card
    end
  end

  def deal(person)
    card = @shoe.pop
    person.hand << card
  end

  def show(dealer, player)
      print "Dealer has: #{dealer.hand_value(dealer.hand)} showing: "
      dealer.hand.each {|card| print card + " "}
      puts ""
      puts ""
      print "You have: #{player.hand_value(player.hand)} showing: "
      player.hand.each {|card| print card + " "}
      puts ""
      puts ""
  end

  def blackjack(dealer, player)
    dealer.show(dealer, player)
    puts "Dealer hit BLACKJACK! You Lose!"
    player.money -= player.bet
    sleep (3.5)
    throw(:blackjack)
  end

  def take_turn(dealer, player)
    begin
      system_clear(player)
      show(dealer, player)
      sleep(1.5)
      if dealer.hit?(dealer.hand_value(dealer.hand))
        puts "Dealer hits"
        sleep(1)
        dealer.deal(dealer)
        system_clear(player)
        show(dealer, player)
      else
        puts "Dealer stays"
        sleep(1)
        break
      end
    end until dealer.bust?(dealer.hand_value(dealer.hand))
  end

  def hit?(hand_value)
    if hand_value < 17
      true
    else
      false
    end
  end

  def declare_winner(dealer, player)
    system_clear(player)
    dealer.show(dealer, player)
    player_value = player.hand_value(player.hand)
    dealer_value = dealer.hand_value(dealer.hand)
    
    if player_value > 21
      puts "You busted!"
      puts ""
      puts "Dealer won!"
      player.money -= player.bet
    elsif dealer_value > 21
      puts "Dealer busted!"
      puts ""
      puts "You won!"
      player.money += player.bet
    elsif player_value > dealer_value
      puts "You won!"
      player.money += player.bet
    elsif dealer_value > player_value
      puts "Dealer won!"
      player.money -= player.bet
    else
      puts "It's a push"
    end
    sleep(2)
  end

  def clear_table(dealer, player)
    dealer.hand.clear
    player.hand.clear
    player.bet = 0
  end

  def check_shoe
    if @shoe.count < 45
      @shoe = Shoe.new(6).shoe.shuffle!
    end
  end

end

class Shoe

  attr_reader :shoe

  def initialize(deck_count)
    @deck = ["|2","|3","|4","|5","|6","|7","|8","|9","|10","|J","|Q","|K","|A"]\
            .product(["H|", "S|", "D|", "C|"]).map {|x| x.join}
    @shoe = @deck * deck_count
  end

end

class Game
  include SystemClear

  attr_reader :player, :dealer
  
  def initialize
    system('cls')
    system('clear')
    @player = Player.new
    @dealer = Dealer.new
  end

  def play_again?
    play_again = false
    begin
      puts "Do you wish to play again? (Y/N)"
      answer = gets.chomp.downcase
    end until answer == 'y' || answer == 'n'
    play_again = true if answer == 'y'
  end

  def play
    begin
      catch(:blackjack) do
        catch(:bust) do
          system_clear(player)
          player.place_bet
          system_clear(player)
          dealer.initial_deal(dealer, player)
          player.blackjack(dealer, player) if player.blackjack?
          dealer.blackjack(dealer, player) if dealer.blackjack?
          player.take_turn(player, dealer)
          throw(:bust) if player.bust?(player.hand_value(player.hand))
          dealer.take_turn(dealer, player)
        end
        dealer.declare_winner(dealer, player)
      end
        dealer.clear_table(dealer, player)
        system_clear(player)
        dealer.check_shoe
      if player.money < 20
        puts "You do not have enough chips to continue playing..."
        break
      end
    end until !play_again?
  end

end

Game.new.play
