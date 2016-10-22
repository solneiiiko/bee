#coding: utf-8
class StatisticController < ApplicationController
  before_action :set_item

  def index
    res = {
      by_days: @bee.stat_by_days,
      by_bee: @bee.stat_by_bee
    }
    
    respond_to do |format|
      format.json {render json: res}
    end
  end

  private

    def set_item
      @bee ||= Answer.new
    end
end