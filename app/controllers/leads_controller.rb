class LeadsController < ApplicationController

    def create
        @lead = Lead.new(lead_params)
        if @lead.save
            render json: {data: {status: "OK"}}
        else
            render json: {data: {status: "ERROR"}}
        end
    end

    def lead_params
        params.require(:lead).permit(
            :destination,
            :current_location,
            :start_date,
            :end_date,
            :travellers_amount,
            :phone,
            :email,
            :name,
            :budget,
            :services,
            :themes,
            :duration
        )
    end
end