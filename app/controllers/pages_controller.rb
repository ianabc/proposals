class PagesController < ApplicationController
  def guidelines
    @guideline = PageContent.first
  end
end
