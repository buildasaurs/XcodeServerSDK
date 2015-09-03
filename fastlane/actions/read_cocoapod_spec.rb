module Fastlane
  module Actions
    module SharedValues
      READ_COCOAPOD_SPEC_JSON = :READ_COCOAPOD_SPEC_JSON
    end

    class ReadCocoapodSpecAction < Action
      def self.run(params)
        path = params[:path] || Dir['*.podspec*'].first

        # will fail if cocoapods is not installed
        require 'cocoapods-core'
        spec = Pod::Spec.from_file(path).to_hash

        Helper.log.info "Reading podspec from file #{path}".green

        Actions.lane_context[SharedValues::READ_COCOAPOD_SPEC_JSON] = spec
        return spec
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Loads a CocoaPods spec as JSON"
      end

      def self.details
        [
          "This can be used for only specifying a version string in your podspec",
          "- and during your release process you'd read it from the podspec by running",
          "`version = read_cocoapod_spec['version']` at the beginning of your lane"
          ].join("\n")
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :path,
                                       env_name: "FL_READ_COCOAPOD_SPEC_PATH",
                                       description: "(Optional) Path to the podspec to be read",
                                       optional: true,
                                       verify_block: proc do |value|
                                          raise "File #{value} not found".red unless File.exists?(spec_path)
                                       end)
        ]
      end

      def self.output
        [
          ['READ_COCOAPOD_SPEC_JSON', 'Podspec JSON payload']
        ]
      end

      def self.authors
        ["czechboy0"]
      end

      def self.is_supported?(platform)
        true
      end
    end
  end
end