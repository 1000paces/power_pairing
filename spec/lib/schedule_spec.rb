require "spec_helper"

describe Schedule do
	before :all do
		@path = "./results.xlsx"
		@results_sheet = "Results"
		@table_sheet = "Table"
		@workbook = Spreadsheet.open(@path)
		@raw_table = Spreadsheet.to_a(@workbook, @table_sheet)
		@raw_schedule = Spreadsheet.to_a(@workbook, @results_sheet)
		@table = Table.to_h(@raw_table)
		@games = Schedule.games(@raw_schedule, @table)
	end
	
	describe ".games" do
		it "returns and array" do
			expect(@games).to be_kind_of(Array)
		end

		it "returns and array of game objects" do
			expect(@games.first).to be_kind_of(Game)
		end

		it "takes two parameters and returns an array of game objects" do
			expect(lambda { games = Schedule.games(1) }).to raise_exception ArgumentError
		end

		it "should load the home_games value from the respective Team" do
			game = @games.first
			home_team = Team.find_by_label(game.home_team, @table)
			expect(home_team.home_games).to eq(5)

			game = @games.last
			home_team = Team.find_by_label(game.home_team, @table)
			expect(home_team.home_games).to eq(4)			
		end
	end

	describe ".preferred_home" do
		it "takes two Team instances as parameters" do
			expect(lambda { games = Schedule.preferred_home(1) }).to raise_exception ArgumentError
		end

		it "returns a string value" do
			team1 = Team.find_by_label("Adams Thunder 3/4 Boys", @table)
			team2 = Team.find_by_label("BH Revolution 3/4 Boys", @table)
			expect(team1).to be_kind_of(Team)
			expect(team2).to be_kind_of(Team)
			retval = Schedule.preferred_home(team1, team2)
			expect(retval).to be_kind_of(String)
		end

		it "returns a pair of teams" do
			team1 = Team.find_by_label("Adams Thunder 3/4 Boys", @table)
			team2 = Team.find_by_label("BH Revolution 3/4 Boys", @table)
			retval = Schedule.preferred_home(team1, team2)
			expect(retval).to eq("16|1")
		end

		it "gives the home game to the team starting with fewer" do
			team1 = Team.find_by_label("Adams Thunder 3/4 Boys", @table)
			team2 = Team.find_by_label("BH Revolution 3/4 Boys", @table)
			retval = Schedule.preferred_home(team1, team2)
			p = retval.split("|")
			ht = @table[p[0].to_i]
			expect(ht.label).to eq(team1.label)
		end
	end

	describe ".pairings" do
		it "takes two parameters: the standings table as a hash and the list of games as an array" do
			expect(lambda { games = Schedule.pairings(1) }).to raise_exception ArgumentError
		end

		it "should return an array" do
			expect(Schedule.pairings(@table, @games)).to be_kind_of(Array)
		end

		it "should return an array of strings" do
			pairings = Schedule.pairings(@table, @games)
			expect(pairings.first).to be_kind_of(String)
		end

		it "should follow the format of 'home_key|away_key'" do
			pairings = Schedule.pairings(@table, @games)
			f = pairings.first
			p1,p2 = f.split("|")
			home_team = @table[p1.to_i]
			away_team = @table[p2.to_i]
			expect(home_team.position.to_i).to eq(p1.to_i)
			expect(away_team.position.to_i).to eq(p2.to_i)
		end

		it "should have half as many elements as the table (plus one more for odd number of teams)" do
			pairings = Schedule.pairings(@table, @games)
			expect(pairings.size).to eq(@table.size/2)
			new_team = Team.new(17, "17th Team", 0,0,5,0,10,0)
			@table[@table.size+1] = new_team
			pairings = Schedule.pairings(@table, @games)
			expect(pairings.size).to eq(9)			
		end

		it "should include one team with a 'BYE' if there are an odd number of teams" do
			new_team = Team.new(17, "17th Team", 0,0,5,0,10,0)
			@table[@table.size+1] = new_team
			pairings = Schedule.pairings(@table, @games)
			x = pairings.index{|i| i.include?("BYE")}
			puts pairings[8]
			expect(x).to be_truthy
		end

		it "should only allow each team one BYE game" do
			new_team = Team.new(17, "17th Team", 0,0,5,0,10,0)
			@table[@table.size+1] = new_team
			pairings = Schedule.pairings(@table, @games)
			x = pairings.index{|i| i.include?("BYE")}
			puts pairings[8]
			expect(x).to be_truthy			
		end

	end
 
end