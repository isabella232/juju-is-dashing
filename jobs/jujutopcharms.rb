#!/usr/bin/env ruby
require 'nokogiri'
require 'open-uri'
require 'mechanize'

# Created by Jonas Rosland, https://github.com/virtualswede, https://twitter.com/virtualswede
# and Kendrick Coleman, https://github.com/kacole2, https://twitter.com/kendrickcoleman
# Template used from https://github.com/foobugs/foobugs-dashboard/blob/master/jobs/twitter_user.rb

# This job tracks metrics of Docker Hub downloads and stars by scraping
# the public website since only stars and not downloads are
# available through the API
#
# This job should use the `List` widget

# Config
# ------

mechanize = Mechanize.new
max_length = 7

SCHEDULER.every '1d', :first_in => 0 do |job|
  page = mechanize.get('https://jujucharms.com/store/')
  charmArray = []
  page.search('.charm').each do |charm|
    next if charmArray.count >= max_length
    charmTitle = charm.at('.charm-name__column h3').text.strip
    charmDeploys = charm.at('.deploys__column p .tip span').text.strip
    charmArray.push({label: charmTitle, value: charmDeploys.to_i})
  end


  send_event('top_charms', { items: charmArray })
end
