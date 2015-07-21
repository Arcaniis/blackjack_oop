# Player enters the amont of money they intend to play with. Player places bet. 
# Dealer deals card to players and himself from the deck. Players hit or stay trying not to bust. 
# Dealer then hits or stays to beat players score and not bust. Money is adjusted. 
# This continues till player cashes out or loses all money.

# Nouns: Player | Dealer | Card | Deck | Money | Hand

# Verbs: Bet | Deal | Hit | Stay | Adjust_Money

module Common

  VALUE_TABLE = {'|2C|' => 2, '|3C|' => 3, '|4C|' => 4, '|5C|' => 5, '|6C|' => 6,
                '|7C|' => 7, '|8C|' => 8, '|9C|' => 9, '|10C|' => 10,
                '|JC|' => 10, '|QC|' => 10, '|KC|' => 10, '|AC|' => 11,
                '|-AC|' => 1, '|2D|' => 2, '|3D|' => 3, '|4D|' => 4, '|5D|' => 5,
                '|6D|' => 6, '|7D|' => 7, '|8D|' => 8, '|9D|' => 9, '|10D|' => 10,
                '|JD|' => 10, '|QD|' => 10, '|KD|' => 10, '|AD|' => 11, '|-AD|' => 1,
                '|2S|' => 2, '|3S|' => 3, '|4S|' => 4, '|5S|' => 5, '|6S|' => 6,
                '|7S|' => 7, '|8S|' => 8, '|9S|' => 9, '|10S|' => 10, '|JS|' => 10,
                '|QS|' => 10, '|KS|' => 10, '|AS|' => 11, '|-AS|' => 1, '|2H|' => 2,
                '|3H|' => 3, '|4H|' => 4, '|5H|' => 5, '|6H|' => 6, '|7H|' => 7,
                '|8H|' => 8, '|9H|' => 9, '|10H|' => 10, '|JH|' => 10, '|QH|' => 10,
                '|KH|' => 10, '|AH|' => 11, '|-AH|' => 1}

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
    return value
  end

  def adjust_bust(hand, hand_value)
    hand.each do |card|
      if hand_value > 21
        if card =~ /\|A.\|/
          card.gsub!(/[A]/, '-A' )
        end
      end
    end
  end

end

class Player
  include Common
  attr_reader :name
  attr_accessor :money, :hand, :bet
  
  def initialize
    puts "=> Please enter your name:"
    @name = gets.chomp
    puts ""
    puts "=> Please enter how much money you will be changing to chips: (EX: $500 = '500')"
    puts "** Minimum bets are $20 **"
    @money = gets.chomp.to_i
    @hand = []
    @bet = 0
  end

  def place_bet
    puts ""
    puts "Please place your bet for this hand:"
    @bet = gets.chomp.to_i
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
  include Common
  attr_accessor :hand

  def initialize(shoe)
    @shoe = shoe
    @hand = []
  end

  def deal(person)
    @card = @shoe.pop
    person.hand << @card
  end

  def hit?(hand_value)
    if hand_value < 17
      true
    else
      false
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
  # attr_accessor :player

  def system_clear(money, bet)
    system('cls')
    system('clear')
    puts "Your chips: $#{money}   Your bet: $#{bet}"
    puts ""
  end

  def show_hidden(dealer_hand, player_hand, player_value)
      puts "Dealer shows: 'HIDDEN' / #{dealer_hand[1]}"
      puts ""
      puts "You have: #{player_value} showing: #{player_hand}"
      puts ""
  end

  def show(dealer_hand, dealer_value, player_hand, player_value)
      puts "Dealer has: #{dealer_value} showing: #{dealer_hand}"
      puts ""
      puts "You have: #{player_value} showing: #{player_hand}"
      puts ""
  end


  def play
    system_clear(0, 0)
    shoe = Shoe.new(6).shoe.shuffle!
    player = Player.new
    dealer = Dealer.new(shoe)
    #LOOP
      system_clear(player.money, player.bet)
      player.place_bet
      system_clear(player.money, player.bet)
      2.times do 
        dealer.deal(dealer)
      end
      2.times do
        dealer.deal(player)
      end
      show_hidden(dealer.hand, player.hand, player.hand_value(player.hand))
      begin
        if player.hit?
          dealer.deal(player)
          player.adjust_bust(player.hand, player.hand_value(player.hand))
          system_clear(player.money, player.bet)
          show_hidden(dealer.hand, player.hand, player.hand_value(player.hand))
        else
          break
        end
      end until player.bust?(player.hand_value(player.hand))
      #if player.bust?(player.hand_value(player.hand))
        #puts "You busted!"
      #end
      begin
        system_clear(player.money, player.bet)
        show(dealer.hand, dealer.hand_value(dealer.hand), player.hand, \
                                        player.hand_value(player.hand))
        sleep(1.5)
        if dealer.hit?(dealer.hand_value(dealer.hand))
          puts "Dealer hits"
          sleep(1)
          dealer.deal(dealer)
          dealer.adjust_bust(dealer.hand, dealer.hand_value(dealer.hand))
          system_clear(player.money, player.bet)
          show(dealer.hand, dealer.hand_value(dealer.hand), player.hand, \
                                        player.hand_value(player.hand))
        else
          puts "Dealer stays"
          sleep(1)
          break
        end
      end until dealer.bust?(dealer.hand_value(dealer.hand))
      #Decide winner
      #Adjust money
      #Play again?
    #END until Play again? == no || No money
  end

end

Game.new.play
