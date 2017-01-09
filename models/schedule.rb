class Schedule

	def self.games(raw_schedule, table_hash)
		games = []
		raw_schedule.each_with_index do |row, index|
			x = row.split(",")
			next if x[0] == 'Game #'
			break if x[1] == ""
			x.each_slice(9) {|game_number, game_date, home_team, home_goals, away_goals, away_team, subround, p1, p2| games << Game.new(game_number, game_date, home_team, home_goals, away_goals, away_team, subround, p1, p2)}

			ht = Team.find_by_label(x[2], table_hash)
			ht.home_games += 1 unless ht.nil?
		end
		return games
	end

	def self.preferred_home(team1,team2)
		if team1.home_games > team2.home_games
			return "#{team2.position}|#{team1.position}"
		else
			return "#{team1.position}|#{team2.position}"
		end
	end	

	def self.print(pairings, table_hash)
		summary_array = []
		pairings.each_with_index do |p,i|
			key1, key2 = p.split("|")
			team1 = table_hash[key1.to_i]
			team2 = table_hash[key2.to_i]
			summary_array << "Game #{i+1}. #{team1.label} (#{team1.position}) vs. #{team2.label} (#{team2.position})"
		end
		return summary_array
	end	

	def self.pairings(table_hash, games)
		pairings = []
		i = 1
		bye_team = nil
		bye_fix = false

		remaining_teams = table_hash.map {|key, value| value}

		table_hash.each do |key, team|
			next unless remaining_teams.include?(team)
			next_opponent, bye = team.next_match(remaining_teams, games)
			if bye
				if bye_team.nil?
					bye_team = team 
				else
					pairings << Schedule.preferred_home(team,bye_team)
					bye_team = nil
					bye_fix = true
				end
			else
				pairings << Schedule.preferred_home(team,next_opponent)
			end
			i += 1
			remaining_teams.delete(next_opponent)
			remaining_teams.delete(team)
		end

		unless bye_team.nil?
			#summary << "BYE: #{bye_team.label} (#{bye_team.position})"
			pairings << "#{bye_team.position}|BYE"
		end

		need_fix = Schedule.check_pairings(pairings, table_hash, games)

		unless need_fix.empty?
			#summary = []
			#puts "PAIRINGS WE NEED TO FIX: #{need_fix}"
			#puts ""
			new_pairings = Schedule.fix_pairings(pairings, need_fix, table_hash, games)
			new_pairings.each do |p|
				pairings[p[0]] = p[1]
			end
			#puts ""
			#puts "REVISED PAIRINGS:"#puts new_pairings
			#puts pairings
		end

		return pairings
	end

	def self.check_pairings(pairings, table_hash, games)
		retval = []
		pairings.each_with_index do |pair, index|
			key1, key2 = pair.split("|")
			team1 = table_hash[key1.to_i]
			team2 = table_hash[key2.to_i]
			if team2.nil?
				#puts "Not a Pair"
				next 
			end
			if team1.opponents(games).include?(team2.label)
				#puts "DAMN, #{team1.position}. #{team1.label} already played #{team2.position}. #{team2.label}"
				retval << "#{team1.position}|#{team2.position}"
			end
		end
		return retval
	end

	def self.fix_pairings(pairings, need_fix, table_hash, games)
		#puts "NEED_FIX IS #{need_fix}"
		
		need_fix.each_with_index do |pair, index|
			bad_match = pairings.index(pair)
			key1, key2 = pair.split("|")
			x = nil
			i = 1
			puts ""
			while x.nil?
				#puts "TRYING #{i}"
				prev_match = pairings[bad_match - i]
				pkey1, pkey2 = prev_match.split("|")
				x = Schedule.check_revision(bad_match,bad_match-i,key1,key2,pkey1,pkey2,table_hash,games)
				break if i > pairings.size
				i += 1
			end
			return x
		end
	end

	def self.check_revision(bad_match, prev_match, key1, key2, pkey1, pkey2, table_hash, games)
		team1 = table_hash[key1.to_i]
		u1 = team1.unmatched(games, table_hash)
		team2 = table_hash[key2.to_i]
		u2 = team2.unmatched(games, table_hash)

		pteam1 = table_hash[pkey1.to_i]
		pteam2 = table_hash[pkey2.to_i]

		if u1.include?(pkey2.to_i) && u2.include?(pkey1.to_i)
			#puts "Switching opponents and preserving H/A worked"
			return [[bad_match, Schedule.preferred_home(team1,pteam2)],[prev_match, Schedule.preferred_home(team2,pteam1)]]
		elsif u1.include?(pkey1.to_i) && u2.include?(pkey2.to_i)
			#puts "Switching opponents but losing H/A worked"
			return [[bad_match, Schedule.preferred_home(team1,pteam1)],[prev_match, Schedule.preferred_home(team2,pteam2)]]
		else
			#puts "This switch doesn't work"
			#puts "AVOID CLUB IS #{$avoid_club}"
			#puts "AVOID REPLAYS IS #{$avoid_replays}"
			if $avoid_club == false && $avoid_replays == true
			#	puts "\t\t***Allow Replays***"
				$avoid_replays = false
			end
			if $avoid_club == true
			#	puts "\t\t***Allow Intra-Club Matchups***"
				$avoid_club = false
			end
			puts ""
			return nil
		end
	end
end