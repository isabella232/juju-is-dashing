require 'httparty'
require 'json'
require 'uri'

# The JUJU Ecosystem Review Queue lives at http://review.juju.solutions
# This class represents a web agent that polls the REVQ every 5 minutes
# and returns the Json response from the front page, or the 'active queue'
#
# Currently there are 2 types of classified items that require attention:
# - New Charms or "incoming"
# - Updated Charms or "updates"

class Revq

    attr_accessor :updates
    attr_accessor :incoming

    def initialize()
        @issues = Hash.new

        json = HTTParty.get('http://review.juju.solutions').body
        response = JSON.parse(json)

        @updates = response['reviews']
        @incoming = response['incoming']

    end


end



SCHEDULER.every '1m', :first_in => 0 do
    r = Revq.new()
    # Send the data for the gauge widgets
    send_event('updates_count', {value: r.updates.count})
    send_event('incoming_count', {value: r.incoming.count})
    send_event('updates_list', {items: r.updates})

end
