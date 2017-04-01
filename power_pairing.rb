require 'date'

Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }

$avoid_club = false
$avoid_replays = true
$verbose = true

season_start = DateTime.new(2017,4,30)
path = "./girls.xlsx"
test_flag = true
bye_team = nil

puts "" if $verbose
puts ""  if $verbose
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

puts "THERE ARE #{games.size} GAMES (INCLUDING BYES)" if $verbose


if need_bye_team
	bye_key, bye_team = Schedule.select_bye_team(table, games)
	puts "BYE TEAM IS #{bye_team.label} (#{bye_team.position})" if $verbose
end

if $verbose
	puts ""
	puts "TABLE"
	puts Table.print(table, games)
	puts ""
end

#### generate the next set of pairings from the table and current game list
pairings = Schedule.pairings(table, games, bye_team)

if $verbose
	puts ""
	puts "PAIRINGS"
	puts pairings
	puts ""	
end

#### write the new lines to the workbook
Spreadsheet.write(workbook, "Results", pairings, table, games, season_start)

#### save the workbook to disk
Spreadsheet.save(workbook, path) if test_flag == false


	puts Schedule.print(pairings, table)


puts "FINISHED PAIRINGS"
