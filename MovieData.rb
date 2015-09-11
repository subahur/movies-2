class MovieData
	
	# constructor that takes a pointer to an array param. If one param is passed then it 
	# loads u.data into the training file and makes test file empty. 
	# A particular training-test can also be specified with another parameter
	def initialize(*param)
		# use of if else in form of overloading the initialize method
		if param.length == 1 
		@training_file = File.join(param[0],"u.data")
		@hash_tables = load_data() # declare a global variable which initializes load_data() so we do not have to do it again and again
		@test_file = nil
		else
		#use hash map to make sure we use approriate data set that corresponds to user input
		mapping_table = {:u1=>["u1.base","u1.test"], :u2=>["u2.base","u2.test"],:u3=>["u3.base","u3.test"],:u4=>["u4.base","u4.est"],:u5=>["u5.base","u5.test"],:ua=>["ua.base","ua.test"],:ub=>["ub.base","ub.test"]}
		@training_file = File.join(param[0],mapping_table[param[1]][0])
		@test_file = File.join(param[0],mapping_table[param[1]][1])
		@hash_tables = load_data() 
		@test_table = load_test()
		end
	end

	def load_data()
		txt = open(@training_file)
		data = txt.read 
		userid_movieid_ratings_ht = { } # hash table one with key = movie id and value = the ratings; 
		movieid_userid_ratings_ht = { }  # an array that will store arrays. Each array will store user_id, movie_id and rating
		data.each_line do |x| 
			y = x.split(' ') # creates an array y which has userid at y[0], movieid at y[1], rating at y[2]
			user_id = y[0].to_i
			movie_id = y[1].to_i
			movie_rating = y[2].to_i
			if userid_movieid_ratings_ht.has_key?(user_id) ==false # the user id does not already exists
				userid_movieid_ratings_ht[user_id] = { } # create another hash table in the key 
			end
			userid_movieid_ratings_ht[user_id][movie_id] = movie_rating # user id already exists add the key = movieid and value = ratings to the respective userid key
			if movieid_userid_ratings_ht.has_key?(movie_id) ==false
				movieid_userid_ratings_ht[movie_id] = { }
			end
			movieid_userid_ratings_ht[movie_id][user_id] = movie_rating # a hash table with movieid at ary[0], userid at ary[1], rating at ary[2] into a already existing array
		end
		hash_tables = {1=>userid_movieid_ratings_ht , 2=>movieid_userid_ratings_ht}
		hash_tables	
	end

	def load_test()
		txt = open(@test_file)
		data = txt.read 
		new_array=[ ]
		data.each_line do |x|
			y = x.split(' ')
			new_array.push( [y[0],y[1],y[2]] )
		end
		new_array
	end

	# returns rating given by user u to movie m
	def rating(u,m)
		if @hash_tables[1][u].has_key?(m) # @userid_movieid_ratings[1] is hash table where each key user contains a hash tables with key=movie and values = ratings
			@hash_tables[1][u][m]
		else
			0 # make sure return 0 when the user has not rated a movie
		end
	end

	def predict(user,movie)
		
		viewers_a = viewers(movie) # all the viewers of movie 
		movies_u = movies(user) # all the movies watched by user  
		popularity = 0
		likeness = 0
		
		if viewers_a != 0 # checks that there are viewers to movie 
			viewers_a.each do |x| # aggregates all the ratings given to m by its watchers 
				popularity = popularity + rating(x,movie).to_f
			end
		end
		if movies_u != 0
			movies_u.each do |x| # aggregates all the ratings given to user u to all the movies he has seen
				likeness = likeness + rating(user,x).to_f
			end
		end 

		if viewers_a == 0 && movies_u == 0
			0
		elsif viewers_a == 0 # when the movie has not been watched by anyone
			likeness/movies_u.length # returns the average of rating user u has given movies he/she has watched
		elsif movies_u == 0 # when there are no movies watched by users 
			popularity/viewers_a.length # return the popularity of the movie
		else
			((likeness/movies_u.length)+(popularity/viewers_a.length))/2 # returns the average of popularity of the movies and whether the user u is an easy rater or hard rater
		end

	end

	#r eturns movies user has seen
	def movies(user)
		if @hash_tables[1].has_key?(user)
			@hash_tables[1][user].keys # return the movies u has seen after finding u in the hashtable
		else 
			0 # return 0 when u has not seen any movies or user inputs invalid user 
		end
			
	end

	# returns a list of viewers of movie  
	def viewers(movie) 
		if @hash_tables[2].has_key?(movie)
			@hash_tables[2][movie].keys # return keys or viewers of movie m
		else
			0 # there are no viewers for the movie
		end

		
	end 
	
	# if the user passes no parameter in run_test then it will run the entire test_table data
	# else if the user specifies the run_test parameter then it will run the test accordingly
	# because we cannot overload method in ruby we ihave used the param's length 
	def run_test(*param) 
		if param.length ==1
			temp = @test_table[0..param[0]-1]
		else
			temp = @test_table
		end
			temp.each do |x|
			x.push(predict(x[0].to_i,x[1].to_i))
		end
		MovieTest.new(temp)
	end

	
end 

class MovieTest

	def initialize(ratings_test)
		@ratings_test = ratings_test
	end

	#returns the mean average of perdiction error
	def mean 
		total = 0
		@ratings_test.each do |x|
			total = total + (x[3].to_f-x[2].to_f).abs
		end
		total/@ratings_test.length
	end

	# returns the standard deviation of mean error
 	def stddev
		temp = mean
		total = 0 
		@ratings_test.each do |x|
			total = total + (((x[3].to_f-x[2].to_f).abs-temp)*((x[3].to_f-x[2].to_f).abs-temp))
		end
		Math.sqrt(total/(@ratings_test.length))
	end

	# returns the mean square error 
	def rms
		total = 0
		@ratings_test.each do |x|
			total = total + (x[3].to_f-x[2].to_f).abs*(x[3].to_f-x[2].to_f).abs
		end
		Math.sqrt(total/@ratings_test.length)
	end

	# prints an array in the form of user movie ratings and prediction
	def to_a 
		@ratings_test.each do |x|
			puts "#{x[0]},#{x[1]},#{x[2]},#{x[3]}"
		end 
 	end 

end 

 z = MovieData.new("ml-100k", :u1)
 puts z.load_data()
 puts z.rating(1,109)
 puts z.movies(943)
 puts z.viewers(1000)
 puts z.predict(1,6)
 t = z.run_test(10000)
 puts t.mean
 puts t.stddev
 puts t.rms
 t.to_a

