class SwoEmailJob < ApplicationJob
  queue_as :default

  def perform(type, record, data)
    # Do something later
  end
end
