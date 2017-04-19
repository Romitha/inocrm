class ContractsController < ApplicationController
	before_filter :find_model

	def contracts
    Organization
    Ticket
    if params[:search].present?
      refined_contract = params[:contract].map { |k, v| "#{k}:#{v}" if v.present? }.compact.join(" AND ")
    end

    params[:query] = refined_contract
    @contracts = TicketContract.search(params)

    # render "tickets/../contracts/contracts"

	private
	def find_model
		@model = Contracts.find(params[:id]) if params[:id]
	end
end