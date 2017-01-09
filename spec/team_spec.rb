require 'spec_helper'
require 'team'

describe Team do

	let(:team_1) do
		Team.new(
				:position => 1,
				:label => "AB Team1",
				:won => 10,
				:drew => 5,
				:lost => 2,
				:gf => 20,
				:ga => 10,
				:home_games => 9
				)
	end

	let(:team_2) do
			Team.new(
					:position => 2,
					:label => "XY Team2",
					:won => 5,
					:drew => 2,
					:lost => 10,
					:gf => 10,
					:ga => 20,
					:home_games => 8
		
					)
	end

	let(:games) do
		Array.new
	end

	describe "attributes" do
		subject do
			Team.new(
				:position => 1,
				:label => "Team1",
				:won => 10,
				:drew => 5,
				:lost => 2,
				:gf => 20,
				:ga => 10,
				:home_games => 9
				)
		end
		it { is_expected.to respond_to(:position) }
		it { is_expected.to respond_to(:label) }
		it { is_expected.to respond_to(:won) }
		it { is_expected.to respond_to(:drew) }
		it { is_expected.to respond_to(:lost) }
		it { is_expected.to respond_to(:gf) }
		it { is_expected.to respond_to(:ga) }
		it { is_expected.to respond_to(:home_games) }
	end

	describe "#points" do
		it "returns the number of points (won*3 + drew) for a team" do
			team_1.points == (team_1.won.to_i*3)+team_1.drew.to_i
			team_2.points == (team_2.won.to_i*3)+team_2.drew.to_i
		end
	end

	describe "#played" do
		it "returns the number of games played (won + drew + lost) for a team" do
			team_1.played == (team_1.won.to_i + team_1.drew.to_i + team_1.lost.to_i)
			team_2.played == (team_2.won.to_i + team_2.drew.to_i + team_2.lost.to_i)
		end
	end

	describe "#scheduled" do
		it "returns the number of games for a team, even if not yet played" do
			expect(team_1.scheduled(games)).to eq(10)
		end
	end

end