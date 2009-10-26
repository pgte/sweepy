module Sweepy
  module Persistence
    class Message
      
     require 'tokyocabinet'
     include TokyoCabinet
      
      def initialize(db_path)
        @db_path = db_path
        @valid_get_errors = [TokyoCabinet::HDB::ESUCCESS, TokyoCabinet::HDB::ENOREC]
        @valid_delete_errors = [TokyoCabinet::HDB::ENOREC]
        Sweepy.log "Persistence layer:DB path = #{db_path}"
      end
      
      def connect
        @db = HDB.new()
        _handle_db_error if !@db.open(@db_path, HDB::OWRITER | HDB::OCREAT)
        Sweepy.log "Persistence layer: connected"
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
        #Sweepy.log "Persistence layer: put(#{key}, #{value})"
        @db.put(key, value) || _handle_db_error 
      end
      
      def delete(key)
        success = @db.delete(key)
        handle_db_error unless success || (@valid_delete_errors.include?(@db.ecode))
      end
      
      def iterinit
        @db.iterinit
      end
      
      def iternext
        @db.iternext
      end

      protected
      
      private
      
      def _handle_db_error
        $stderr.puts @db.errmsg(@db.ecode) 
      end
      
    end
  end
end
