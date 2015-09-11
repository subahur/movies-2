class MovieData
	
	#constructor that takes a pointer to an array param. If one param is passed then it 
	#loads u.data into the training file and makes test file empty. 
	#A particular training-test can also be specified with another parameter
	def initialize(*param)
		#use of if else in form of overloading the initialize method
		if param.length == 1 
		@training_file = File.join(param[0],"u.data")
		@h_table = load_data() #declare a global variable which initializes load_data() so we do not have to do it again and again
		@test_file = nil
		else
		@training_file = File.join(param[0],"u1.base")
		@test_file = File.join(param[0],"u1.test")
		@h_table = load_data() 
		@test_table = load_test()
		end
	end

	def load_data()
		txt = open(@training_file)
		data = txt.read 
		h_table = { }
		h_table_one = { } #hash table one with key = movie id and value = the ratings; 
		h_table_two = [ ] #an array that will store arrays. Each array will store user_id, movie_id and rating
		data.each_line do |x| 
			y = x.split(' ')
			if h_table_one.has_key?(y[0]) ==false
				h_table_one[y[0]] = { }
				h_table_one[y[0]][y[1]] = y[2] 
				#h_table_one[y[0]].push([y[1].to_i,y[2].to_i])
			else 
				h_table_one[y[0]][y[1]] = y[2] 
				#h_table_one[y[0]].push([y[1].to_i,y[2].to_i])
			end
		end
		data.each_line do |x|
			y = x.split(' ')
			ary = Array.new
			ary.push(y[0],y[1],y[2])
			h_table_two.push(ary)
		end
		h_table[1] = h_table_one 
		h_table[2] = h_table_two 
		return h_table	
	end

	def load_test()
		txt = open(@test_file)
		data = txt.read 
		new_array=[ ]
		data.each_line do |x|
			y = x.split(' ')
			new_array.push( [y[0],y[1],y[2]] )
		end
		return new_array
	end

	#returns rating given by user u to movie m
	def rating(u,m)
		#hash_table is hash table where each key user contains a hash tables with key=movie and values = ratings
		hash_table = @h_table[1]
		if hash_table[u].has_key?(m)
			return hash_table[u][m]
		else
			return 0
		end
	end

	def predict(u,m)
		viewers_a = viewers(m)
		movies_u = movies(u)
		popularity = 0
		likeness = 0
		viewers_a.each do |x|
			popularity = popularity + rating(x,m).to_f
		end
		movies_u.each do |x|
			likeness = likeness + rating(u,x).to_f
		end
		if viewers_a.length==0 
			return likeness/movies_u.length
		else 
			return ((likeness/movies_u.length)+(popularity/viewers_a.length))/2
		end

	end

	#returns movies user u has seen
	def movies(u)
		#hash_table is hash table where each key user contains a hash tables with key=movie and values = ratings
		hash_table = @h_table[1]
		movies_a = [ ]
		hash_table[u].keys.each do |x|
			movies_a.push(x)
		end 
		return movies_a
	end

	#returns a list of viewers of movie m 
	def viewers(m)
		hash_table = @h_table[1]
		viewers_a = [ ]
		hash_table.keys.each do |x|
			viewer_n = x 
			if hash_table[x].has_key?(m)
				viewers_a.push(viewer_n)
			end
		end
		return viewers_a
	end 

	

	#runs the predict method till k in the test set and returns an object of 
	#MovieTest class containing the results. 
	#def run_test(k)
	#	new_array = @test_table[0..k-1]
	#	new_array.each do |x|
	##		prediction = predict(x[0],x[1])
	#		x.push(prediction)
	#	end
	#	return MovieTest.new(new_array)
	#end
	def run_test(k)
		hash_table = @test_table#[2]
		ratings_test = [ ]
		temp_array = 
		hash_table[0..k-1].each do |x|
			prediction = predict(x[0],x[1])
			ary = Array.new
			ary.push(x[0],x[1],x[2],prediction)
			ratings_test.push(ary)
		end
		return MovieTest.new(ratings_test)
	end

end 

class MovieTest

	def initialize(ratings_test)
		@ratings_test = ratings_test
	end

	#returns the mean average of perdiction error
	def mean 
		new_array = @ratings_test
		total = 0
		new_array.each do |x|
			if x[3].to_f>x[2].to_f
				y = x[3].to_f-x[2].to_f
			else 
				y = x[2].to_f-x[3].to_f
			end
			total = total + y 
		end
			return total/new_array.length
	end

	#returns the standard deviation of mean error
	def stddev
		new_array = @ratings_test
		temp = self.mean
		total = 0 
		new_array.each do |x|
			if x[3].to_f>x[2].to_f
				y = x[3].to_f-x[2].to_f
			else 
				y = x[2].to_f-x[3].to_f
			end
			total = total + ((y-temp)*(y-temp))
		end
		return Math.sqrt(total/(new_array.length-1))
	end

	#returns the mean square error 
	def rms
		new_array = @ratings_test
		total = 0
		new_array.each do |x|
			if x[3].to_f>x[2].to_f
				y = x[3].to_f-x[2].to_f
			else 
				y = x[2].to_f-x[3].to_f
			end
			total = total + y*y 
		end
		return Math.sqrt(total/new_array.length)
	end

	#prints an array in the form of user movie ratings and prediction
	def to_a 
		new_array = @ratings_test
		new_array.each do |x|
			puts "#{x[0]},#{x[1]},#{x[2]},#{x[3]}"
		end 
	end 

end 

z = MovieData.new("ml-100k","u1.test") 
#puts z.load_data()
#puts z.rating("1","10")
#puts z.movies("1")
#puts z.viewers("1")
#puts z.predict("9","17")
t = z.run_test(20000)
puts t.mean
#t.to_a