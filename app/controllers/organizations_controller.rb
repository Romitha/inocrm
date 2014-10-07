class OrganizationsController < ApplicationController
  before_action :authenticate_user!

  def index
    @organizations = Organization.order("created_at DESC")
  end

  def new
    @organization = Organization.new
  end
end
