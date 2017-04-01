class Team
  attr_accessor :club, :label, :position, :won, :drew, :lost, :gf, :ga, :home_games, :away_games, :scheduled_games, :byes

  def initialize(position=nil, label=nil, won=nil, drew=nil, lost=nil, gf=nil, ga=nil, home_games=0, away_games=0)
    @position = position
    @label = label
    @won = won
    @drew = drew
    @lost = lost
    @gf = gf
    @ga = ga
    @home_games = home_games
    @away_games = away_games
  end

  def points 
    return (won.to_i * 3) + drew.to_i
  end

  def played
    return won.to_i + lost.to_i + drew.to_i
  end

  def scheduled(games, include_byes=true)
    x = self.opponents(games, include_byes).size
    return x
  end

  def goal_diff
    return gf.to_i - ga.to_i
  end

  def club
    x = label.split(" ")
    return x[0]
  end

  def next_match(remaining_teams, games)
    oppo = ""
    assigned_bye = false
    Logger.info("FINDING OPPONENT FOR #{self.label} FROM #{remaining_teams.map{ |m| m.label }}")
    remaining_teams.each do |team|
      next if team.label == self.label #### don't want to play yourself
      return team if team == remaining_teams.last #&& remaining_teams.size <=2
      next if $avoid_club && team.club == self.club #### avoid playing another team in the same club
      next if $avoid_replays && self.opponents(games).include?(team.label) #### avoid replays
      oppo = team
      return oppo
    end

    return "FUCK"
    #return Team.new(0,"BYE"), true
    #return Team.new(0,"CAN'T PAIR")
  end

  def eligible_for_bye?(games)
    games.each do |game|
      next if game.nil?
      if game.away_team == 'BYE' && game.home_team == self.label
        Logger.info("\t\t#{game.home_team} HAD A BYE ALREADY")
        return false
      end
    end
    return true
  end

  def opponents(games, include_byes=true)
    retval = []
    
    games.each do |game|
      next if game.nil?
      if [game.home_team, game.away_team].include?(self.label)
        next if include_byes == false && game.away_team == 'BYE'
        if self.label == game.home_team
          retval << game.away_team
        else
          retval << game.home_team
        end
      end
    end
    return retval
  end

  def unmatched(games, table_hash)
    oppo = self.opponents(games)
    retval = []

    table_hash.each do |key, team|
      retval << key if !oppo.include?(team.label) && self.label != team.label
    end
    return retval
  end

  def self.find_by_label(label, table_hash)
    team = table_hash.select {|key, value| value.label == label}
    return team.values[0]
  end

  def bye_eligible
    false
  end

end