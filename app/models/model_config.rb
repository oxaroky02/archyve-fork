class ModelConfig < ApplicationRecord
  class ModelTypeError < StandardError; end

  has_many :messages, as: :author, dependent: :destroy

  scope :generation, -> { where(embedding: false) }
  scope :embedding, -> { where(embedding: true) }
  scope :default, -> { where(default: true) }

  def make_active_embedding_model
    raise ModelTypeError, "Model is not an embedding model" unless embedding?

    Setting.find_by(key: "embedding_model").update!(value: id)
  end

  def make_default_chat_model
    raise ModelTypeError, "Model is an embedding model" if embedding?

    Setting.find_by(key: "chat_model").update!(value: id)
  end

  def make_active_summarization_model
    raise ModelTypeError, "Model is an embedding model" if embedding?

    Setting.find_by(key: "summarization_model").update!(value: id)
  end
end
