module TfOutputs
  module Configurator
    class StateConfigurator
      attr_accessor :state_uris

      BACKENDS = { s3: 'S3StateConfiguration',
                   file: 'FileStateConfiguration' }.freeze

      Dir.glob("#{File.dirname(__FILE__)}/backends/*").each do |filename|
        require_relative "backends/#{File.basename(filename)}"
      end

      def initialize(states_array)
        @states_array = states_array
      end

      def file_list
        file_list = []
        @states_array.each do |state_hash|
          backend_name = state_hash[:backend]
          class_name = BACKENDS[backend_name.to_sym]
          clazz = Object.const_get("TfOutputs::Configurator::Backends::#{class_name}")
          state = clazz.new (state_hash[:options])
          file_list.push(state.save)
        end
        file_list
      end
    end
  end
end
