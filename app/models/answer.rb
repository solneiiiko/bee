#coding: utf-8
require 'csv'

class Answer
	# При инициализации читаем файлы
	# считаем, что данные идельные
	# записываем во внутренние переменные
	def initialize(opts={})
		@harvest = opts[:harvest] || CSV.read("public/csv_files/harvest.csv")

		@harvest_title = Hash[@harvest.first.map{|fn| fn.gsub(/(\s)/, '') }.zip @harvest.first.size.times] rescue {}

		@pollens = opts[:pollens] || CSV.read("public/csv_files/pollens.csv")
		@pollens_title = Hash[@pollens.first.zip @pollens.first.size.times] rescue {}
		@pollens = Hash[ @pollens[1..-1].map{|rec| [rec[@pollens_title['id']], rec] } ] rescue {}
	end

	def a
		@harvest_title
	end

	# Выполнили подсчет для разных вариантов

	# Из пыльцы какого типа было получено больше всего сахара?
	def a1
		return nil if @harvest.length<2
		
		group_pollen = @harvest[1..-1].group_by{|rec| rec[@harvest_title['pollen_id']]}
		
		res = group_pollen.map do |k,v|
			val_sugar_per_mg = @pollens[k][@pollens_title['sugar_per_mg']].to_f
			[k, v.map{|e| e[@harvest_title['miligrams_harvested']].to_f}.sum * val_sugar_per_mg]
		end

		@pollens[res.sort{|a,b| b[1]<=>a[1]}.first.first][@pollens_title['name']]
	end

	# Какая пыльца была наиболее популярна среди пчел?
	def a2
		return nil if @harvest.length<2
		
		group_pollen = @harvest[1..-1].group_by{|rec| rec[@harvest_title['pollen_id']]}

		res = group_pollen.map do |k,v|
			[k, v.map{|e| e[@harvest_title['miligrams_harvested']].to_f}.sum]
		end
	
		@pollens[res.sort{|a,b| b[1]<=>a[1]}.first.first][@pollens_title['name']]
	end


	# Какой день был самым лучшим для сбора урожая? Какой был худшим? (Было бы здорово увидеть таблицу или график, который показывает общее количество сахара за каждый день)
	def stat_by_days
		return {} if @harvest.length<2
		
		group_pollen = @harvest[1..-1].group_by{|rec| rec[@harvest_title['day']]}
		
		res = group_pollen.map do |k,v|
			v.map! do |rec|
				pollen_id = rec[@harvest_title['pollen_id']]
				val_sugar_per_mg = @pollens[pollen_id][@pollens_title['sugar_per_mg']].to_f

				rec[@harvest_title['miligrams_harvested']].to_f * val_sugar_per_mg
			end

			[k, v.sum]
		end

		res
	end

	# Какая пчела была наиболее эффективной? Какая была наименее эффективной? Эффективность измеряется как среднее количество сахара за все рабочие дни (Было бы здорово увидеть таблицу для всех пчел)
	def stat_by_bee
		return {} if @harvest.length<2

		group_pollen = @harvest[1..-1].group_by{|rec| rec[@harvest_title['bee_id']]}

		res = group_pollen.map do |k,v|
			# сгруппируем для каждой пчелы по дням
			group_days = v.group_by{|rec| rec[@harvest_title['day']]}

			# посчитаем сумму за каждый день
			# не map! т к hash
			group_days = group_days.map do |day, rec_arr|
				rec_arr.map! do |rec|
					pollen_id = rec[@harvest_title['pollen_id']]
					val_sugar_per_mg = @pollens[pollen_id][@pollens_title['sugar_per_mg']].to_f

					rec[@harvest_title['miligrams_harvested']].to_f * val_sugar_per_mg
				end

				[day, rec_arr.sum]
			end

			avg = group_days.map{|e| e[1].to_f }.sum / group_days.length 

			[k, avg]
		end

		res
	end

end