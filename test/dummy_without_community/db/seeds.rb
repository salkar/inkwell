salkar = User.create :nick => "Salkar"
morozovm = User.create :nick => "Morozovm"

salkar_post1 = salkar.posts.create :title => "salkar_post1"
salkar_post2 = salkar.posts.create :title => "salkar_post2"
morozovm_post1 = morozovm.posts.create :title => "morozovm_post1"
morozovm_post2 = morozovm.posts.create :title => "morozovm_post2"
