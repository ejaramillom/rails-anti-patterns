# bad

class PetsController < ApplicationController
  def show
    @pet = Pet.find(params[:id])
    @toys = Toy.where(:pet_id => @pet.id, :cute => true)
  end
end

# improved

class PetsController < ApplicationController
  def show
    @pet = Pet.find(params[:id])
    @toys = Toy.find_cute_for_pet(@pet)
  end
end

class Toy < ActiveRecord::Base
  def self.find_cute_for_pet(pet)
    where(:pet_id => pet.id, :cute => true)
  end
end

# better

class PetsController < ApplicationController
  def show
    @pet = Pet.find(params[:id])
    @toys = @pet.find_cute_toys
  end
end

class Pet < ActiveRecord::Base
  has_many :toys
    
  def find_cute_toys
    self.toys.where(:cute => true)
  end
end

# good

class PetsController < ApplicationController
  def show
    @pet = Pet.find(params[:id])
    @toys = @pet.toys.cute
  end
end

class Toy < ActiveRecord::Base
  def self.cute
    where(:cute => true)
  end
end

class Pet < ActiveRecord::Base
  has_many :toys
end

# best

class PetsController < ApplicationController
  def show
    @pet = Pet.find(params[:id])
    @toys = @pet.toys.cute.paginate(params[:page])
  end
end

class Toy < ActiveRecord::Base
  scope :cute, where(:cute => true)
end

class Pet < ActiveRecord::Base
  has_many :toys
end

# scope extension

class Toy < ActiveRecord::Base
  # has column :minimum_age
end

class Pet < ActiveRecord::Base
  # has column :age
  has_many :toys do
    def appropriate
      where(["minimum_age < ?", proxy_owner.age])
    end
  end
end