
require 'json'
require 'pry-byebug'
require 'optparse'
DEFAULT_FILE_NAME = 'products.json'
class ProductSearch
  #init function
  def initialize
      @file_data = []
      @file_name = ""
      @organized_data = {"tshirt": Array.new, "mug": Array.new, "sticker": Array.new}
      @product_type = ARGV.shift
      if(ARGV.length > 0)
        @options = ARGV
      else
        @options = []
      end
  end

  #init data
  def data
    @file_data
  end

  #function to load data, organize data, create a user response, and return a response to the user via cli
  def process_file
    fname = verify_file 
    if fname
      @file_data = File.read(fname)
      load_data
      organize_data
      handle_data
      return_data @data
    end   
  end

  #function to check if the default file path works, if not prompt user for a new file path until a readable file is found.
  def verify_file 
    file_name = DEFAULT_FILE_NAME
    while !File.exist?(file_name) do 
      file_name =  get_new_file
    end
    return file_name
  end

  #function to get a new file path if the default file path given cannot be found
  def get_new_file
    prompt_user
    return STDIN.gets.chomp
  end

  #function to prompt the user to input a new file put as a string
  def prompt_user
      puts 'please provide path to products file'
  end

  #function to load the product data
  def load_data
      @file_data = JSON.parse(@file_data)
  end

  #function to organize data into an easier to handle data structure
  def organize_data
    @file_data.each do |data| 
        if data["product_type"] == "tshirt"
        @organized_data[:tshirt].push(data["options"])
        elsif data["product_type"] == "sticker"
        @organized_data[:sticker].push(data["options"])
        else data["product_type"] == "mug"
        @organized_data[:mug].push(data["options"])
        end
      end 
  end

  #creates the user response by calling the appropriate handle method (determined by product_type selected by the user)
  def handle_data
    data = nil
    if @product_type == "tshirt"
      data = handle_shirts
    elsif @product_type == "sticker"
      data = handle_stickers
    elsif @product_type == "mug"
      data = handle_mugs
    else #case where user enters an improper product_type
      data  = {Message: ["Incorrect product_type entered"]}
    end
    if data == nil
      puts "Invalid options or product type input"
      return
    end

    #set global variable data to reflect the newly constructed response
    @data = data 
  end

  #filters out the data to be returned to the user based on the options given
  def return_data hash
    
    @options.each do |option|
      hash.each do |key,val|
        if val.include? option
          hash.delete key
        end
      end
    end 
    hash.each do |key,val|
      puts "#{key}: #{val}"
    end
  end

  #function to handle custom options for tshirts
  def handle_shirts 
    gender = Array.new
    color = Array.new
    size = Array.new
    #if there are no options present, return all shirt options to the user
    if @options.length == 0
      data = print_all_shirts
      return data
    end
    #for each option the user presents, see if the hash contains its value
    @options.each do |option|
      @organized_data[:tshirt].each do |hash|
        if hash.has_value? @options[0] #if the hash has its value, check to see if there is a second option
          if @options.length > 1
            if hash.has_value? @options[1] #if the hash also contains the value of the second option, add the hash to our response list
              gender.push(hash["gender"])
              color.push(hash["color"])
              size.push(hash["size"])
            end
          else  #if there is only one option and it satisfies the user request, add the hash to our response list
            gender.push(hash["gender"])
            color.push(hash["color"])
            size.push(hash["size"])
          end
        end
      end
    end

    data = {Gender: gender.uniq!, Color: color.uniq!, Size: size.uniq!} #remove duplicates and return user response as a hash
    return data
  end


  #function to handle custom options for mugs
  def handle_mugs
    type = Array.new

    #if there are no options selected, return all mug options to the user
    if @options.length == 0
      data = print_all_mugs
      return data
    end

    #check to see for each option if the value is contained within the hash
    @options.each do |option|
      @organized_data[:mug].each do |hash|
        if hash.has_value? @options[0] #if the hash has the value that the user is searching for, add the type to the data for response
            type.push(hash["type"]) 
        end
      end
    end

    data = {Type: type.uniq}
    return data
  end

  #function to handle custom options for stickers
  def handle_stickers
    size = Array.new
    style = Array.new

    #if there are no options present, return all sticker options to the user
    if @options.length == 0
      data = print_all_stickers
      return data 
    end

    #

    #for each option, check to see if the hash contains its value (currently functions for two options maximum)
    @options.each do |option|
      @organized_data[:sticker].each do |hash|
        if hash.has_value? @options[0] #does the hash satisfy the first value?
          if @options.length > 1 #is there a second option?
            if hash.has_value? @options[1] #does the hash satisfy the second value?
              size.push(hash["size"])
              style.push(hash["style"])
            end
          else
            size.push(hash["size"])
            style.push(hash["style"])
          end
        end
      end
    end

    data = {Size: size.uniq, Style: style} #remove duplicate data and returns a hash with the user's response
    return data
  end

  #function to return all tshirt options
  def print_all_shirts
    gender = Array.new
    color = Array.new
    size = Array.new
    @organized_data[:tshirt].each do |hash|
      gender.push(hash["gender"])
      color.push(hash["color"])
      size.push(hash["size"])
    end
    data = {Gender: gender.uniq!, Color: color.uniq!, Size: size.uniq!}
    return data
  end

  #function to return all mug options
  def print_all_mugs
    type = Array.new
    @organized_data[:mug].each do |hash|
      type.push(hash["type"]) 
    end 

    data = {Type: type}
    return data
  end

  #function to return all sticker options
  def print_all_stickers
    size = Array.new
    style = Array.new
    @organized_data[:sticker].each do |hash|
      size.push(hash["size"])
      style.push(hash["style"])
    end
    data = {Size: size.uniq!, Style: style.uniq!}
    return data
  end

end
