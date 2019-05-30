# frozen_string_literal: true

module Vitae
  # Behaviors of the currently logged in account
  class Sheet
    attr_reader :id, :name, :file_id,
                :owner, :collaborators, :documents, :policies

    def initialize(sheet_info)
      process_attributes(sheet_info['attributes'])
      process_relationships(sheet_info['relationships'])
      @policies = OpenStruct.new(sheet_info['policies'])
    end

    private

    def process_attributes(attributes)
      @id = attributes['id']
      @name = attributes['name']
      @file_id = attributes['file_id']
    end

    def process_relationships(relationships)
      return unless relationships

      @owner = Account.new(relationships['owner']['attributes'])
      @collaborators = process_collaborators(relationships['collaborators'])
    end

    def process_collaborators(collaborators)
      return nil unless collaborators

      collaborators.map { |account_info| Account.new(account_info['attributes']) }
    end
  end
end