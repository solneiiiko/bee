#coding: utf-8
require 'csv'

class Answer
	# При инициализации читаем файлы
	# считаем, что данные идельные, те если пришли столбцы, то точно есть нужные
	# записываем во внутренние переменные
	def initialize(opts={})
		@harvest = opts[:harvest] || CSV.read("public/csv_files/harvest.csv") rescue []

		@harvest_title = Hash[@harvest.first.map{|fn| fn.gsub(/(\s)/, '') }.zip @harvest.first.size.times] rescue {}

		@pollens = opts[:pollens] || CSV.read("public/csv_files/pollens.csv") rescue []
		@pollens_title = Hash[@pollens.first.zip @pollens.first.size.times] rescue {}
		@pollens = Hash[ @pollens[1..-1].map do |rec|
			# На самом деле на время не влияет
			rec[@pollens_title['sugar_per_mg']] = rec[@pollens_title['sugar_per_mg']].to_f 
			[rec[@pollens_title['id']], rec]
		end ] rescue {}
	end

	# Из пыльцы какого типа было получено больше всего сахара?
	def best_pollen
		# Если нет данных, то ничего не делаем
		return nil if @harvest.length<2 || @pollens.length<2
		
		# Сгруппируем по типу пыльцы и map массив c елементами [тип пыльцы (id), количество сахара]
		# Отсортируем по количеству сахара (убывание) и получим тип пыльцы (id)
		res = (@harvest[1..-1].group_by{|rec| rec[@harvest_title['pollen_id']]}.map do |k,v|
			val_sugar_per_mg = @pollens[k][@pollens_title['sugar_per_mg']]
			[k, v.map{|e| e[@harvest_title['miligrams_harvested']].to_f}.sum * val_sugar_per_mg]
		end).sort{|a,b| b[1]<=>a[1]}.first.first

		# По id пыльцы получим ее имя и его вернем
		@pollens[res][@pollens_title['name']]
	end

	# Какая пыльца была наиболее популярна среди пчел?
	def popular_pollen
		# Если нет данных, то ничего не делаем
		return nil if @harvest.length<2 || @pollens.length<2
		
		# Сгруппируем по типу пыльцы и map массив c елементами [тип пыльцы (id), количество в мг]
		# Отсортируем по количеству мг (убывание) и получим тип пыльцы (id)
		res = (@harvest[1..-1].group_by{|rec| rec[@harvest_title['pollen_id']]}.map do |k,v|
			[k, v.map{|e| e[@harvest_title['miligrams_harvested']].to_f}.sum]
		end).sort{|a,b| b[1]<=>a[1]}.first.first
	
		# По id пыльцы получим ее имя и его вернем
		@pollens[res][@pollens_title['name']]
	end


	# Статистика по сахару за каждый день
	def stat_by_days
		# Если нет данных, то ничего не делаем
		return [] if @harvest.length<2 || @pollens.length<2

		# Если статистика посчитана, то можно вернуть ее же (тк долго считается, лучше закешировать).
		return @stat_by_days if @stat_by_days 

		# Сгруппируем по типу дням и map массив c елементами [день, количество сахара]
		# Отсортируем по дням (возрастание) и получим массив для вывода статистики 
		@stat_by_days = (@harvest[1..-1].group_by{|rec| rec[@harvest_title['day']]}.map do |k,v|
			v.map! do |rec|
				pollen_id = rec[@harvest_title['pollen_id']]
				val_sugar_per_mg = @pollens[pollen_id][@pollens_title['sugar_per_mg']]

				rec[@harvest_title['miligrams_harvested']].to_f * val_sugar_per_mg
			end

			[k, v.sum]
		end).sort{|a,b| a.first<=>b.first}

		@stat_by_days
	end

	# Какой день был самым лучшим для сбора урожая? Какой был худшим?
	def best_and_worst_day
		# Возьмем результат, если уже считали (во вьюшке спрашиваем 2 раза)
		return @best_and_worst_day if @best_and_worst_day

		# Отсортируем по количеству сахара
		res = self.stat_by_days.sort{|a,b| a[1]<=>b[1]}

		@best_and_worst_day = {best: res.last[0], worst: res.first[0]} rescue { best: nil, worst: nil }
	end

	# Какая пчела была наиболее эффективной? Какая была наименее эффективной? Эффективность измеряется как среднее количество сахара за все рабочие дни (Было бы здорово увидеть таблицу для всех пчел)
	def stat_by_bee
		# Если нет данных, то ничего не делаем
		return [] if @harvest.length<2 || @pollens.length<2
		
		# Если статистика посчитана, то можно вернуть ее же (тк долго считается, лучше закешировать).
		return @stat_by_bee if @stat_by_bee 

		# Сгруппируем по пчелам и map с елементами [id пчелы(int), среднее количество сахара за день]
		# Отсортируем по id пчелы для вывода
		@stat_by_bee = (@harvest[1..-1].group_by{|rec| rec[@harvest_title['bee_id']]}.map do |k,v|
			# сгруппируем для каждой пчелы по дням
			group_days = v.group_by{|rec| rec[@harvest_title['day']]}

			# посчитаем сумму за каждый день(вдруг день указан для пчелы несколько раз), например разные виды пыльцы
			# не map! т к hash
			group_days = group_days.map do |day, rec_arr|
				rec_arr.map! do |rec|
					pollen_id = rec[@harvest_title['pollen_id']]
					val_sugar_per_mg = @pollens[pollen_id][@pollens_title['sugar_per_mg']]

					rec[@harvest_title['miligrams_harvested']].to_f * val_sugar_per_mg
				end

				[day, rec_arr.sum]
			end

			# Посчитаем среднее значение за каждый день, в который доывалась пыльца
			avg = group_days.map{|e| e[1].to_f }.sum / group_days.length 

			# id в int для правильной сортировки
			[k.to_i, avg]
		end).sort{|a,b| a.first<=>b.first}

		@stat_by_bee
	end

	def best_and_worst_bee
		# Возьмем результат, если уже считали (во вьюшке спрашиваем 2 раза)
		return @best_and_worst_bee if @best_and_worst_bee

		# Отсортируем по среднему количеству сахара
		res = self.stat_by_bee.sort{|a,b| a[1]<=>b[1]}

		@best_and_worst_bee = {best: res.last[0], worst: res.first[0]} rescue { best: nil, worst: nil }
	end

	# Можно посмотреть производительность, но на стандартных данных смысла не имеет
	# Можно сгенерировать, но можно просто размножить уже имеющиеся в файле
	def self.benchmark(n=10)
		ans = self.new
		harvest = ans.instance_variable_get :@harvest

		# с 1, тк в 0 находится шапка таблицы
		n.times.each { harvest += harvest[1..-1] }
		ans.instance_variable_set(:@harvest, harvest)
		Benchmark.bm do |x|
		  x.report('.best_pollen') 	 { ans.best_pollen }
		  x.report('.popular_pollen'){ ans.popular_pollen }
		  x.report('.stat_by_days')  { ans.stat_by_days }
		  x.report('.stat_by_bee') 	 { ans.stat_by_bee }
		end
	end
						
end

#  Answer.benchmark 15
#        user     system      total        real
# .best_pollen 15.440000   0.060000  15.500000 ( 15.493378)
# .popular_pollen 14.940000   0.060000  15.000000 ( 14.988206)
# .stat_by_days 24.800000   0.050000  24.850000 ( 24.844300)
# .stat_by_bee 32.180000   0.020000  32.200000 ( 32.182741)
