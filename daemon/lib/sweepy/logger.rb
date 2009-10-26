module Sweepy
  def self.log(message)
    if Choice.choices.verbose
      puts "[#{Time.now.to_s}] #{message}"
    end
  end
  def self.err(message)
    $stderr.puts "[#{Time.now.to_s}] #{message}"
  end
end