#!/usr/bin/env ruby

require 'rack'

module Flapjack
  module Gateways
    class JSONAPI < Sinatra::Base
      module Rack
        class JsonParamsParser < Struct.new(:app)
          def call(env)
            t = type(env)
            if env['rack.input'] and not input_parsed?(env) and type_match?(t)
              env['rack.request.form_input'] = env['rack.input']
              json_data = env['rack.input'].read
              env['rack.input'].rewind

              data = Oj.load(json_data)
              env['rack.request.form_hash'] = data.empty? ? {} :
                (('application/json-patch+json'.eql?(t)) ? {'ops' => data} : data)
            end
            app.call(env)
          end

          def input_parsed? env
            env['rack.request.form_input'].eql? env['rack.input']
          end

          def type(env)
            return unless env['CONTENT_TYPE']
            env['CONTENT_TYPE'].split(/\s*[;,]\s*/, 2).first.downcase
          end

          def type_match?(t)
            Flapjack::Gateways::JSONAPI::JSON_REQUEST_MIME_TYPES.include?(t)
          end
        end
      end
    end
  end
end
