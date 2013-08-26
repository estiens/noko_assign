require 'rubygems'
require 'nokogiri'
require "rest-client"

EPL_TABLE_URL= "http://www.premierleague.com/en-gb/matchday/league-table.html"

page = Nokogiri::HTML(RestClient.get(EPL_TABLE_URL))

teams= page.css(".leagueTable td.col-club").map(&:text)
wins = page.css(".col-w").map(&:text)
losses = page.css(".col-l").map(&:text)
draw = page.css(".col-d").map(&:text)


class Team
  attr_accessor :name, :wins, :losses, :draws

def initialize(name,wins,losses,draws)
   @name=name
   @wins=wins
   @losses=losses
   @draws=draws
 end

def points
   points=(3*wins.to_i)+ draws.to_i
end

end
@team=[]
for x in (0..19)
  # instancename="team#{x+1}"
  # puts instancename
  @team[x]=Team.new(teams[x],wins[x+1],losses[x+1], draw[x+1])
  # puts "#{instancename} is #{instancename.name} with #{instancename.wins} wins #{instancename.losses} losses and #{instancename.draws} draws"
  # puts "#{instancename.name} has #{instancename.points.to_s} points"
end
@team.each do |x|
  puts "#{x.name}"
end

for x in (0..19)
  puts "#{@team[x].name} has #{@team[x].points} points"
end


