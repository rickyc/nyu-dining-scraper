require 'rubygems'  
require 'activesupport'
require 'nokogiri'  
require 'open-uri'  

# Feeds
# Weinstein Broken
# http://www.campusdish.com/en-US/CSE/NYU/Locations/WeinsteinDiningHallMenu.htm
# Hayden Broken
# http://www.campusdish.com/en-US/CSE/NYU/Locations/HaydenDiningHallMenu.htm
LOCATIONS = [
  'http://www.campusdish.com/en-US/CSE/NYU/Locations/ThirdNorthMenu.htm?LocationName=Third%20North%20Menu&OrgID=193900&ShowPrice=False&ShowNutrition=True',
  'http://www.campusdish.com/en-US/CSE/NYU/Locations/PalladiumFoodCourtMenu.htm?LocationName=Palladium%20Food%20Court%20Menu&OrgID=193900&ShowPrice=False&ShowNutrition=True',
  'http://www.campusdish.com/en-US/CSE/NYU/Locations/RubinDiningHallMenu.htm?LocationName=Rubin%20Dining%20Hall%20Menu&OrgID=193900&ShowPrice=False&ShowNutrition=True'
]

# Scraper
hsh = {}
LOCATIONS.each do |url|
  date = '5/1/2011'.to_date

  # Loop through three weeks from the starting date, 5/1, 5/8, 5/15
  (1..3).each do 
    base_url = "#{url}&Date=#{date.month}_#{date.day}_#{date.year}"

    # MealID for GET param (16 is lunch, 17 is dinner, 603 is brunch)
    [16,17,603].each do |i|

      # Brunch only occurs for Palladium
      break if (i == 603 && url.index('Palladium').nil?)

      cuisine, tdate = '', date
      meal = (i == 16) ? 'lunch' : (i == 17) ? 'dinner' : (i == 603) ? 'brunch' : '' 

      final_url = "#{base_url}&MealID=#{i}"
      doc = Nokogiri::HTML(open(final_url))  
      root = doc.xpath("//td[@align='left' and @bgcolor='#ffffff']")[1]

      root.xpath(".//table").each do |type|
        tmp_cuisine = type.xpath(".//td[@class='ConceptTabText']").inner_html

        if !tmp_cuisine.eql?('')
          cuisine = tmp_cuisine
          tdate = date
          hsh[cuisine] = []
        else
          type.xpath(".//td[@class='menuBorder']").each do |item| 
            item.xpath(".//a").each do |food_item| 
              # Generating the Hash
              ary = item.xpath(".//a").collect do |a| 
                { :date => tdate, :item => a.inner_text.downcase, :meal => meal }
              end
              hsh[cuisine] << ary
              tdate = tdate + 1.day
            end
          end
        end
      end

    end
    date += 7.days
  end
end

puts hsh.to_json
