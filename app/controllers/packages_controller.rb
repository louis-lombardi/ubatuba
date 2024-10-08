class PackagesController < ApplicationController
    def index
        render json: {data: Package.all}
    end
end