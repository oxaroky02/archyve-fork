module LlmClients
  class Client
    MODEL_TEMPLATE_MAP = {
      "^gemma:" => { prefix: "<start_of_turn>user\n", suffix: "<end_of_turn>\n<start_of_turn>model" },
      "^mi[xs]tral:" => { prefix: "<s>[INST]", suffix: "[/INST] " }
    }.freeze

    attr_reader :stats

    def initialize(endpoint:, api_key:, model:, temperature: default_temperature, batch_size: default_batch_size)
      @endpoint = endpoint
      @api_key = api_key
      @model = model
      @temperature = temperature
      @batch_size = batch_size

      @uri = URI("#{@endpoint}/#{completion_path}")
    end

    private

    def headers
      headers = { "Content-Type": "application/json" }
      headers[:Authorization] = "Bearer #{@api_key}" if @api_key

      headers
    end

    def context(prompt, model)
      template = template_for(model)

      "#{template[:prefix]}#{prompt}#{template[:suffix]}"
    end

    def template_for(model)
      MODEL_TEMPLATE_MAP.each do |name, template|
        if model =~ Regexp.new(name)
          return template
        end
      end

      { prefix: "", suffix: "" }
    end

    def response_error_for(response)
      additional_info = [response.uri]

      error = begin
        JSON.parse(response.body)[response_error_field]
      rescue JSON::ParserError
        nil
      end
      additional_info.append(error) if error

      ResponseError.new(
        "Server responded with #{response.code}: #{response.message}", additional_info
      )
    end

    def response_error_field
      "error"
    end

    def new_stats
      {
        start_time: nil,
        end_time: nil,
        elapsed_ms: nil,
        tokens: 0,
        tokens_per_sec: nil
      }
    end

    def calculate_stats
      @stats[:end_time] = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      elapsed_s = (@stats[:end_time] - @stats[:start_time])
      @stats[:elapsed_ms] = (elapsed_s * 1000).to_i
      @stats[:tokens_per_sec] = (@stats[:tokens] / elapsed_s).round(2)
    end

    def default_temperature
      0.1
    end

    def default_batch_size
      256
    end
  end
end