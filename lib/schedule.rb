module Schedule

  def self.games(raw_schedule, table_hash)
    games = []
    raw_schedule.each_with_index do |row, index|
      x = row.split(",")
      next if x[0] == 'Game #'
      break if x[1] == ""
      x.each_slice(9) {|game_number, game_date, home_team, home_goals, away_goals, away_team, subround, p1, p2| games << Game.new(game_number, game_date, home_team, home_goals, away_goals, away_team, subround, p1, p2)}

      ht = Team.find_by_label(x[2], table_hash)
      ht.home_games += 1 unless ht.nil?

      at = Team.find_by_label(x[5], table_hash)
      at.away_games += 1 unless at.nil?
    end
    return games
  end

  def self.preferred_home(team1,team2)
    if team2.position == 0
      return "#{team1.position}|#{team2.position}"
    end
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
      if team2.nil?
        summary_array << "Game #{i+1}. #{team1.label} (#{team1.position}) vs. BYE"
      else
        summary_array << "Game #{i+1}. #{team1.label} (#{team1.position}) vs. #{team2.label} (#{team2.position})"
      end
    end
    return summary_array
  end 

  def self.pairings(table_hash, games, bye_team=nil)
    pairings = []
    i = 1
    remaining_teams = table_hash.map {|key, value| value}
    puts "REMOVING BYE TEAM (#{bye_team.label}) FROM THIS WEEKS PAIRING" if $verbose && !bye_team.nil?
    remaining_teams.delete(bye_team) unless bye_team.nil?
    
    table_hash.each do |key, team|
      next if !bye_team.nil? && team.label == bye_team.label
      next unless remaining_teams.include?(team)
      
      next_opponent = team.next_match(remaining_teams, games)
      if 1==2# bye
        if bye_team.nil?
          puts "\t\tSET THE BYE TEAM TO #{team.label}" if $verbose
          bye_team = team
          #pairings << "#{team.position}|BYE"
          #need_a_bye = false
        else
          puts "WE ALREADY HAVE A BYE THIS ROUND: #{bye_team.label} (#{bye_team.position})" if $verbose
          puts "\tDOES #{team.label} HAVE A BYE? #{!team.eligible_for_bye?(games)}" if $verbose
          if team.eligible_for_bye?(games)
            prev_bye_team = bye_team
            bye_team = team
            remaining_teams.delete(bye_team)
            remaining_teams << prev_bye_team
            next_opponent, bye = prev_bye_team.next_match(remaining_teams, games, false)
            pairings << Schedule.preferred_home(prev_bye_team,next_opponent)
          end
         # pairings << Schedule.preferred_home(team,bye_team)
          #bye_team = nil
          #bye_fix = true
        end
      else
      #  pairings << Schedule.preferred_home(team,next_opponent)
      end
      puts "(#{team.position}) #{team.label} vs. (#{next_opponent.position}) #{next_opponent.label}"
      pairings << Schedule.preferred_home(team,next_opponent)
      i += 1
      remaining_teams.delete(next_opponent)
      remaining_teams.delete(team)
    end

    pairings << "#{bye_team.position}|BYE" unless bye_team.nil?
    
    #### Look for pairings that have already happened
    puts "" if $verbose
    need_fix = Schedule.check_pairings(pairings, table_hash, games, bye_team)

    unless need_fix.empty?
      new_pairings = Schedule.fix_pairings(pairings, need_fix, table_hash, games)
      new_pairings.each do |p|
        pairings[p[0]] = p[1]
      end
    end

    return pairings
  end

  def self.check_pairings(pairings, table_hash, games, bye_team)
    puts "BYE TEAM IS #{bye_team.label}"
    retval = []
    pairings.each_with_index do |pair, index|
      puts "EXAMINE #{pair}" if $verbose
      key1, key2 = pair.split("|")
      team1 = table_hash[key1.to_i]
      next if bye_team == team1
      team2 = table_hash[key2.to_i]
      if team2.nil?
        retval << "#{team1.position}|0"
        next 
      end
      if $avoid_replays == true
        if team1.opponents(games).include?(team2.label)
          retval << "#{team1.position}|#{team2.position}"
        end
      end
    end
    puts "NEEDS FIXING: #{retval.empty? ? 'NOTHING' : retval}" if $verbose
    return retval
  end

  def self.fix_pairings(pairings, need_fix, table_hash, games)
    #puts "NEED_FIX IS #{need_fix}"
    
    need_fix.each_with_index do |pair, index|
      bad_match = pairings.index(pair)
      key1, key2 = pair.split("|")
      x = nil
      i = 1
      while x.nil?
        puts "TRYING #{i}" if $verbose
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
      puts "Switching opponents and preserving H/A worked" if $verbose
      return [[bad_match, Schedule.preferred_home(team1,pteam2)],[prev_match, Schedule.preferred_home(team2,pteam1)]]
    elsif u1.include?(pkey1.to_i) && u2.include?(pkey2.to_i)
      puts "Switching opponents but losing H/A worked" if $verbose 
      return [[bad_match, Schedule.preferred_home(team1,pteam1)],[prev_match, Schedule.preferred_home(team2,pteam2)]]
    else
      puts "This switch doesn't work" if $verbose
      puts "AVOID CLUB IS #{$avoid_club}" if $verbose
      puts "AVOID REPLAYS IS #{$avoid_replays}" if $verbose
      if $avoid_club == false && $avoid_replays == true
        puts "\t\t***Allow Replays***" if $verbose
        $avoid_replays = false
      end
      if $avoid_club == true
        puts "\t\t***Allow Intra-Club Matchups***" if $verbose
        $avoid_club = false
      end
      puts ""
      return nil
    end
  end

  def self.determine_byes(table, games)
    team_hash = Hash.new
    table.each do |k,v|
      t = Team.find_by_label(v.label, table)
      t.byes = 0
    end

    games.each do |game|
      next if game.nil?
      if game.away_team == 'BYE'
        t = Team.find_by_label(game.home_team, table) 
        t.byes += 1
      end
    end
    return table
  end

  def self.select_bye_team(table, games)
    table = self.determine_byes(table, games)
    bye_team = table.min_by{ |k,v| v.byes }
    return bye_team
  end
end