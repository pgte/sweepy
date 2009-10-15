module Sweepy
  module Persistence
    class Message
      
     require 'tokyocabinet'
     include TokyoCabinet
      
      def db
        if !@db
          
        end
        
      end
      
      def initialize(db_path)
        @db_path = db_path
        @valid_get_errors = [TokyoCabinet::HDB::ESUCCESS, TokyoCabinet::HDB::ENOREC]
        puts "DB path = #{db_path}"
      end
      
      def connect
        @db = HDB.new()
        _handle_db_error if !@db.open(@db_path, HDB::OWRITER | HDB::OCREAT)
        puts "connected"
      end
      
      def disconnect
        handle_db_error if !@db.close
      end
      
      def get(key)
        value = @db.get(key)
        _handle_db_error unless @valid_get_errors.include? @db.ecode
        value
      end

      def put(key, value)
        puts "put(#{key}, #{value})"
        @db.put(key, value) || _handle_db_error 
      end

      protected
      
      private
      
      def _handle_db_error
        puts @db.errmsg(@db.ecode) 
      end
      
    end
  end
end
