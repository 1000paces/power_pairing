require 'date'
require 'optparse'

Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }

options = {verbose: false, avoid_replays: true, avoid_club: false, test_mode: false}

OptionParser.new do |opts|
	opts.on("-v", "--verbose", "Verbose mode.") do |v|
		options[:verbose] = v
	end
	opts.on("-r", "--replays", "Don't pair replays of previous games.") do |r|
		options[:avoid_replays] = r
	end	
	opts.on("-c", "--club", "Don't pair intra-club games") do |c|
		options[:avoid_club] = c
	end
	opts.on("-t", "--test", "Run in Test Mode, don't save anything") do |t|
		options[:test_mode] = t
	end	
	opts.on("-f", "--file FILE", "File to process (including path)") do |f|
		options[:file] = f
	end
	opts.on("-b", "--bye BYE", "Assign BYE to a specific team (pass integer representing position in table") do |b|
		options[:bye] = b
	end	
end.parse!

$avoid_club = options[:avoid_club]
$avoid_replays = options[:avoid_replays]
$verbose = options[:verbose]
$test_flag = options[:test_mode]

Logger.info("RUNNING IN VERBOSE MODE")

season_start = DateTime.new(2017,4,30)
Logger.info("FILE IS #{options[:file]}")
path = options[:file] #"./girls.xlsx"
bye_team = nil

Logger.info("\n\n")
puts "*** BEGIN PAIRING *** " 
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
	if options[:bye].empty?
		bye_key, bye_team = Schedule.select_bye_team(table, games)
	else
		Logger.info("MANUALLY ASSIGNING BYE TO #{options[:bye]}")
		bye_key = options[:bye].to_i
		bye_team = table[bye_key]
	end
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
puts "*** PAIRINGS COMPLETE ***"
Logger.info("\n\n")
