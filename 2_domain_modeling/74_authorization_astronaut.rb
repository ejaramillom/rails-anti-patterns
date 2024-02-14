# bad

class UserRole < ApplicationRecord
  belongs_to :user
  belongs_to :role
end

class Role < ApplicationRecord
  has_many :user_roles
  has_many :users, through: :user_roles

  validates_presence_of :name
  validates_uniqueness_of :name
  
  def name=(value)
    write_attribute("name", value.downcase)
  end
  
  def self.[](name) # Get a role quickly by using: Role[:admin]
    self.find(:first, conditions: ["name = ?", name.id2name])
  end
  
  def add_user(user)
    self.users << user
  end
end

class User < ApplicationRecord
  # has_and_belongs_to_many :roles, uniq: true
  has_many :user_roles
  has_many :roles, through: :user_roles, uniq: true
  
  def has_role?(role_in_question)
    self.roles.first(conditions: { name: role_in_question }) ? true : false
  end
  
  def has_roles?(roles_in_question)
    roles_in_question = self.roles.all(conditions: ["name in (?)",  roles_in_question])
    roles_in_question.length > 0
  end
  
  def can_post?
    self.has_roles?(['admin',  'editor',  'associate editor',  'research writer'])
  end
  
  def can_review_posts?
    self.has_roles?(['admin', 'editor', 'associate editor'])
  end
  
  def can_edit_content?
    self.has_roles?(['admin', 'editor', 'associate editor'])
  end
  
  def can_edit_post?(post)
    self == post.user ||
    self.has_roles?(['admin', 'editor', 'associate editor'])
  end
end

# Never build beyond the application requirements at the time you are writing the code.
# If you do not have concrete requirements, don’t write any code.
# Don’t jump to a model prematurely; there are often simple ways, such as using Booleans and denormalization, to avoid adding models.
# If there is no user interface for adding, removing, or managing data, there is no need for a model. A denormalized column populated by a hash or array of possible values is fine.

# good

class User < ActiveRecord::Base
  has_many :roles
  
  Role::TYPES.each do |role_type|
    define_method "#{role_type}?" do
      roles.exists?(name: role_type)
    end
  end
end

class Role < ActiveRecord::Base
  TYPES = %w(admin editor writer guest)
  
  validates :name, inclusion: {in: TYPES}
end
