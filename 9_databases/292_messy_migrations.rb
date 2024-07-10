# bad (never modify the up method on a commited migration)

rake db:migrate
rake db:migrate:redo

# The rake db:migrate:redo command runs the down method on the last migration and then reruns the up method on that migration. This ensures that the entire migration runs in both directions and is repeatable, without error. Once you’ve run this and double-checked the results, you can commit your new migration to the repository with confidence.

# bad (never use external code in a migration)

class AddJobsCountToUser < ActiveRecord::Migration[6.0]
  def self.up
    add_column :users, :jobs_count, :integer, default: 0
    
    Users.all.each do |user|
      user.jobs_count = user.jobs.size
      user.save
    end
  end

  def self.down
    remove_column :users, :jobs_count
  end
end

# good (run sql directly)

class AddJobsCountToUser < ActiveRecord::Migration[6.0]
  def self.up
    add_column :users, :jobs_count, :integer, :default => 0
    
    update(<<-SQL)
      UPDATE users SET jobs_count = (
        SELECT count(*) FROM jobs
        WHERE jobs.user_id = users.id
      )
    SQL
  end
  
  def self.down
    remove_column :users, :jobs_count
  end
end

# good (always provide down methods in your migrations)

def self.down
  raise ActiveRecord::IrreversibleMigration
end

# bad (wet validations. which means repeating the constrains of rails directly in the database)

class User < ActiveRecord::Base
  validates :account_id, :presence => true
  validates :first_name, :presence => true
  validates :last_name, :presence => true
  validates :password, :presence => true,  :confirmation => true, :if => :password_required?
  validates :email, :uniqueness => true, :format => { :with => %r{.+@.+\..+} }, :presence => true
  belongs_to :account
end

self.up
  create_table :users do |t|
    t.column :email, :string, :null => false
    t.column :first_name, :string, :null => false
    t.column :last_name, :string, :null => false
    t.column :password, :string
    t.column :account_id, :integer
  end
  execute “ALTER TABLE users ADD UNIQUE (email)”
  execute “ALTER TABLE users ADD CONSTRAINT
  user_constrained_by_account FOREIGN KEY (account_id) REFERENCES
  accounts (id) ON DELETE CASCADE”
end

self.down
  execute “ALTER TABLE users DROP FOREIGN KEY
  user_constrained_by_account”
  drop_table :users
end

# It’s simply best to not fight the opinion of Active Record that database constraints are declared in the model and that the database should simply be used as a datastore.
