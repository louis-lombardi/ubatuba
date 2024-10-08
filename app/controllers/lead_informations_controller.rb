class LeadInformationsController < ApplicationController
    def index
        render json: {data: LeadInformation.all}
    end
end