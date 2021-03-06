# frozen_string_literal: true

require_relative './app'

module Vitae
  # Sheets controller for Vitae API
  class App < Roda
    route('sheet') do |r|
      r.redirect '/auth/login' unless @current_account.logged_in?

      @sheets_route = '/sheets'

      r.on String do |file_id|
        # GET /sheet/FID/edit
        r.is 'edit', method: :get do
          view :edit,
               locals: { current_user: @current_account, file_id: file_id }
        end

        r.is 'view', method: :get do
          # GET /sheet/FID/view
          sheet = GetSheet.new(App.config).call(account: @current_account, file_id: file_id)
          view :sheet,
               locals: { current_user: @current_account,
                         sheet: Sheet.new(sheet)}
        end

        r.is 'delete', method: :post do
          # POST /sheet/[FID]/delete
          DeleteSheet.new(App.config).call(account: @current_account, file_id: file_id)
        rescue StandardError
          flash[:error] = 'Could not delete CV'
        ensure
          r.redirect @sheets_route
        end

        # POST /sheets/[FID]/collabs
        r.post('collabs') do
          action = r.params['action']
          collaborator_info = Form::CollabEmail.call(r.params)
          if collaborator_info.failure?
            flash[:error] = Form.validation_errors(collaborator_info)
            r.halt
          end

          task_list = {
            'add' => { service: CollabAdd,
                        message: 'Added new collaborator to CV' },
            'remove' => { service: CollabRemove,
                          message: 'Removed collaborator from CV' }
          }

          task = task_list[action]
          task[:service].new(App.config).call(
            current_account: @current_account,
            collaborator: collaborator_info,
            file_id: file_id
          )
          flash[:notice] = task[:message]

        rescue StandardError
          flash[:error] = 'Could not find collaborator'
        ensure
          r.redirect @sheets_route
        end
      end
    end
  end
end
