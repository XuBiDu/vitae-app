# frozen_string_literal: true

# Service to add collaborator to sheet
class CollabAdd
  class CollabNotAdded < StandardError; end

  def initialize(config)
    @config = config
  end

  def api_url
    @config.API_URL
  end

  def call(current_account:, collaborator:, file_id:)
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .put("#{api_url}/sheet/#{file_id}/collabs",
                           json: { email: collaborator[:email] })

    raise CollabNotAdded unless response.code == 200
  end
end

# Service to add collaborator to sheet
class CollabRemove
  class CollabNotRemoved < StandardError; end

  def initialize(config)
    @config = config
  end

  def api_url
    @config.API_URL
  end

  def call(current_account:, collaborator:, file_id:)
    response = HTTP.auth("Bearer #{current_account.auth_token}")
                   .delete("#{api_url}/sheet/#{file_id}/collabs",
                           json: { email: collaborator[:email] })

    raise CollabNotRemoved unless response.code == 200
  end
end
