# terrible

class ArticlesController < ApplicationController
  def create
    @article = Article.new(params[:article])
    @article.reporter_id = current_user.id

    Article.transaction do
      @version = @article.create_version!(params[:version], current_user)
    rescue ActiveRecord::RecordNotSaved, ActiveRecord::RecordInvalid
      render action: :index and return false
    end
  
  redirect_to article_path(@article)
end

# better

## app/controllers/articles_controller.rb
  
class ArticlesController < ApplicationController
  def create
    @article = Article.new(params[:article])
    @article.reporter = current_user
    @article.new_version.writer = current_user
    
    if @article.save
      render :action => :index
    else
      redirect_to article_path(@article)
    end
  end
end
  
## app/models/article.rb
  
class Article < ActiveRecord::Base
  def new_version=(version_attributes)
    @new_version = versions.build(version_attributes)
  end
  
  def new_version
    @new_version
  end
end

  ## app/models/version.rb

class Version < ActiveRecord::Base
  before_validation :set_version_number, :on => :create
  before_create :mark_related_links_not_current,  :if => :current_version
  after_create :set_current_version_on_article
  
  private
  
  def set_current_version_on_article
    article.update_attribute :current_version_id, self.id
  end
end  