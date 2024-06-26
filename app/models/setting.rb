class Setting < ApplicationRecord
  class << self
    def chat_model
      chat_model_id = find_by(key: 'chat_model')&.value

      return if chat_model_id.nil?

      ModelConfig.find(chat_model_id)
    end

    def embedding_model
      embedding_model_id = find_by(key: 'embedding_model')&.value

      return if embedding_model_id.nil?

      ModelConfig.find(embedding_model_id)
    end

    def summarization_model
      summarization_model_id = find_by(key: 'summarization_model')&.value

      return if summarization_model_id.nil?

      ModelConfig.find(summarization_model_id)
    end
  end
end
