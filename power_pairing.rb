require 'date'
#require 'rubyXL'

Dir[File.dirname(__FILE__) + '/lib/*.rb'].each {|file| require file }

$avoid_club = false
$avoid_replays = true
season_start = DateTime.new(2016,9,11)
path = "./results.xlsx"
verbose = true
test_flag = true

#### open the spreadsheet
workbook = Spreadsheet.open(path)

#### turn the Table sheet into an array
raw_table = Spreadsheet.to_a(workbook, "Table")

#### get a hash of the raw table
table = Table.to_h(raw_table)

#### get the schedule to date into an array
raw_schedule = Spreadsheet.to_a(workbook, "Results")
#### get array of game objects from the raw schedule
games = Schedule.games(raw_schedule, table)

if verbose
	puts ""
	puts "TABLE"
	puts Table.print(table, games)
end

#### generate the next set of pairings from the table and current game list
pairings = Schedule.pairings(table, games)

if verbose
	puts ""
	puts "PAIRINGS"
	puts pairings
	puts ""	
end

#### write the new lines to the workbook
Spreadsheet.write(workbook, "Results", pairings, table, games, season_start)

#### save teh workbook to disk
Spreadsheet.save(workbook, path) if test_flag == false

if verbose
	puts Schedule.print(pairings, table)
end


