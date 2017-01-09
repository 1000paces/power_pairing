class Team
	attr_accessor :club, :label, :position, :won, :drew, :lost, :gf, :ga, :home_games

	def initialize(position=nil, label=nil, won=nil, drew=nil, lost=nil, gf=nil, ga=nil, home_games=0)
		@position = position
		@label = label
		@won = won
		@drew = drew
		@lost = lost
		@gf = gf
		@ga = ga
		@home_games = home_games
	end

	def points 
		return (won.to_i * 3) + drew.to_i
	end

	def played
		return won.to_i + lost.to_i + drew.to_i
	end

	def scheduled(games)
		x = self.opponents(games).size
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
		remaining_teams.each do |team|
			next if team.label == self.label #### don't want to play yourself
			next if $avoid_club && team.club == self.club #### avoid playing another team in the same club
			next if $avoid_replays && self.opponents(games).include?(team.label) #### avoid replays
			oppo = team
			return oppo, false
		end
		return Team.new(0,"BYE"), true
	end

	def opponents(games)
		retval = []
		
		games.each do |game|
			#puts "GAME DATE IS #{game.game_date}"
			next if game.nil?
			#next if game.home_goals.nil? || game.away_goals.nil?
			#next if game.home_goals.empty? || game.away_goals.empty?
			if [game.home_team, game.away_team].include?(self.label)
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
		#puts "FOUND #{team}"
		return team.values[0]
	end

end