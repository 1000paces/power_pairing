require 'date'
require 'optparse'

Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }

options = {verbose: false, avoid_replays: true, avoid_club: false, test_mode: false}

OptionParser.new do |opts|
	opts.on("-v", "--verbose", "Verbose Mode") do |v|
		options[:verbose] = v
	end
	opts.on("-r", "--replays", "Avoid Replays") do |v|
		options[:avoid_replays] = v
	end	
	opts.on("-c", "--club", "Avoid Intra-Club Games") do |v|
		options[:avoid_club] = v
	end
	opts.on("-t", "--test", "Test Mode") do |v|
		options[:test_mode] = v
	end	
end.parse!

$avoid_club = options[:avoid_club]
$avoid_replays = options[:avoid_replays]
$verbose = options[:verbose]
$test_flag = options[:test_mode]

Logger.info("RUNNING IN VERBOSE MODE")

season_start = DateTime.new(2017,4,30)
path = "./girls.xlsx"
bye_team = nil

Logger.info("\n\n")
puts "START PAIRING" 
#### open the spreadsheet
workbook = Spreadsheet.open(path)

#### turn the Table sheet into an array
raw_table = Spreadsheet.to_a(workbook, "Table")
need_bye_team = raw_table.size.even? #### Even because there is a header row.  

#### get a hash of the raw table
table = Table.to_h(raw_table)

#### get the schedule to date into an array
raw_schedule = Spreadsheet.to_a(workbook, "Results")

#### get array of game objects from the raw schedule
games = Schedule.games(raw_schedule, table)

Logger.info("THERE ARE #{games.size} GAMES (INCLUDING BYES)")


if need_bye_team
	bye_key, bye_team = Schedule.select_bye_team(table, games)
	Logger.info("BYE TEAM IS #{bye_team.label} (#{bye_team.position})")
end

Logger.info("\n")
Logger.info("TABLE")
Logger.info(Table.print(table, games))
Logger.info("\n")

#### generate the next set of pairings from the table and current game list
pairings = Schedule.pairings(table, games, bye_team)

Logger.info("\n")
Logger.info("PAIRINGS")
Logger.info(pairings)
Logger.info("\n")


#### write the new lines to the workbook
Spreadsheet.write(workbook, "Results", pairings, table, games, season_start)

#### save the workbook to disk
Spreadsheet.save(workbook, path) if $test_flag == false

Logger.info(Schedule.print(pairings, table))
puts "FINISHED PAIRINGS"
Logger.info("\n\n")
