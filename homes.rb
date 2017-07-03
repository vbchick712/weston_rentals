# gems required for this code to work
require 'mechanize'
require 'csv'

# Using Mechanize to instantiate a new web scraper
scraper = Mechanize.new

# This delays the rate limit of scraping to once every 1/2 second to prevent
# getting an IP address blocked from a site
scraper.history_added = Proc.new { sleep 0.5 }

# Addresses set up in variables to call on easier throughout the code
BASE_URL = 'https://miami.craigslist.org'
ADDRESS = 'https://miami.craigslist.org/search/apa?search_distance=5&postal=33327'

# This will store all of the results
results = []

# This sets the names of the header rows for the CSV file
results << ['Title', 'Rent', 'Location', 'URL']

# This is the command for the scraper to get the data from the target page
scraper.get(ADDRESS) do |search_page|

  # This uses Mechanize to enter data into the search fields on the page to
  # scope the data pulled
  search_form = search_page.form_with(:id => 'searchform') do |search|

    search['housing_type'] = 6
    search['min_bedrooms'] = 3
    search['max_bedrooms'] = 3
    search['min_bathrooms'] = 2
    search['max_bathrooms'] = 2
  end
  results_page = search_form.submit

  # this pulls the raw data we want to search through and format for output
  raw_results = results_page.search('li.result-row')

  # This parses out the results so we get the exact data we want formatted to our specs
  raw_results.each do |result|
    link = result.css('a')[1]
    title = link.text.strip
    rent = result.search('span.result-price').text[0..4]
    url = BASE_URL + link.attributes["href"].value
    location = result.search('span.result-hood').text

    # This saves the results in the order we designate
    results << [title, rent, location, url]
  end

  # This creates the CSV file with the data we scraped from the web page
  CSV.open("homes.csv", "w+") do |csv_file|
    results.each do |row|
      csv_file << row
    end
  end

end
