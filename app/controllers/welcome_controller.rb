#coding: utf-8
class WelcomeController < ApplicationController
	before_action :set_item

	def index
	end

	private

		def set_item
			@bee ||= Answer.new
		end
end