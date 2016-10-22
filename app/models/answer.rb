#coding: utf-8
require 'csv'

class Answer
	# При инициализации читаем файлы
	# записываем во внутренние переменные
	def initialize(opts={})
		@harvest = opts[:harvest] || CSV.read("public/csv_files/harvest.csv")

		@harvest_title = {}
		@harvest.first.each_with_index{|f, i| @harvest_title[f] = i }
		
		@pollens = opts[:pollens] || CSV.read("public/csv_files/pollens.csv")
		@pollens_title = {}
		@pollens.first.each_with_index{|f, i| @pollens_title[f] = i }
	end

	# Выполнили подсчет для разных вариантов
	# возвращаем hash

	# Из пыльцы какого типа было получено больше всего сахара?
	def a1
		# [@harvest_title, @pollens_title]
	end

	# Какая пыльца была наиболее популярна среди пчел?
	def a2
	end

	# Какой день был самым лучшим для сбора урожая? Какой был худшим? (Было бы здорово увидеть таблицу или график, который показывает общее количество сахара за каждый день)
	def a3
	end

	# Какая пчела была наиболее эффективной? Какая была наименее эффективной? Эффективность измеряется как среднее количество сахара за все рабочие дни (Было бы здорово увидеть таблицу для всех пчел)	def answer_1
	def a4
	end

end