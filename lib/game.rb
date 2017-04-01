class Game
  attr_accessor :game_number, :game_date, :home_team, :home_goals, :away_goals, :away_team, :subround, :p1, :p2

  def initialize(game_number=nil, game_date=nil, home_team=nil, home_goals=nil, away_goals=nil, away_team=nil, subround=nil, p1=nil, p2=nil)
    @game_number = game_number
    @game_date = game_date
    @home_team = home_team
    @home_goals = home_goals
    @away_goals = away_goals
    @away_team = away_team
    @subround = subround
    @p1 = p1
    @p2 = p2
  end

  def winner
    if self.home_goals.to_i == self.away_goals.to_i
      "Draw"
    elsif self.home_goals.to_i > self.away_goals.to_i
      "#{home_team} won"
    else
      "#{away_team} won"
    end
  end

  def bye?
    away_team == "BYE"
  end

end