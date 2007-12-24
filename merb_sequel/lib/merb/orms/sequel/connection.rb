require "fileutils"

module Merb
  module Orms
    module Sequel
      class << self
        def config_file() MERB_ROOT / "config" / "database.yml" end
        def sample_dest() MERB_ROOT / "config" / "database.sample.yml" end
        def sample_source() File.dirname(__FILE__) / "database.sample.yml" end
      
        def copy_sample_config
          FileUtils.cp sample_source, sample_dest unless File.exists?(sample_dest)
        end
      
        def config
          @config ||=
            begin
              # Convert string keys to symbols
              full_config = Erubis.load_yaml_file(config_file)
              config = (Merb::Plugins.config[:merb_sequel] = {})
              (full_config[MERB_ENV.to_sym] || full_config[MERB_ENV]).each { |k, v| config[k.to_sym] = v }
              config
            end
        end
      
        # Database connects as soon as the gem is loaded
        def connect
          require "sequel"

          if File.exists?(config_file)
            puts "#{Time.now.httpdate}: Connecting to the '#{config[:adapter]}' database '#{config[:hosts]}' ..."
            connection = ::Sequel.connect(config_options(config))
            MERB_LOGGER.error("Connection Error: #{e}") unless connection
          else
            copy_sample_config
            puts "#{Time.now.httpdate}: No database.yml file found in #{MERB_ROOT}/config."
            puts "A sample file was created called config/database.sample.yml for you to copy and edit."
            exit(1)
          end
        end
        
        def config_options(config = {})
          options = {}
          options[:adapter]  = (config[:adapter]  || "sqlite")
          options[:host]     = (config[:host]     || "localhost")
          options[:user]     = (config[:username] || config[:user] || "root")
          options[:password] = config[:password] if config[:password]
          if (config[:encoding] || config[:charset])
            options[:encoding] = (config[:encoding] || config[:charset])
          end
          options[:database] = config[:database]  if config[:database]
          options[:logger]   = MERB_LOGGER
          options
        end
        
        # Registering this ORM lets the user choose sequel as a session store
        # in merb.yml's session_store: option.
        def register_session_type
          Merb::Server.register_session_type("sequel",
            "merb/session/sequel_session",
            "Using Sequel database sessions")
        end

      end
    end
  end

end
