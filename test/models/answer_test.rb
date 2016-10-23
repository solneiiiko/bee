#coding: utf-8
require 'test_helper'

class AnswerTest < ActiveSupport::TestCase
  
  # %i(a1 a2 a3 a4).each do |method_name|
  #   test "#{method_name} с пустыми данными" do
  #     answer = Answer.new(harvest: [], pollens: [])
  #     assert_equal answer.method(method_name).call, []    
  #   end
  # end

  #Из пыльцы какого типа было получено больше всего сахара: a1
  test "действительно ли значение считаем с двух таблиц, а не берем самое большое в какой-то" do
    pollens = [
      %w(id name sugar_per_mg),
      ['1', 'name1', '10'],
      ['2', 'name2', '1'],
      ['3', 'name3', '5']
    ]

    harvest = [
      %w(bee_id day pollen_id miligrams_harvested),
      ['1', '2013-04-01', '2', '20'],  # 20
      ['2', '2013-05-01', '1', '1.5'], # 15
      ['3', '2013-04-07', '3', '7']    # 35
    ]

    answer = Answer.new(harvest: harvest, pollens: pollens)

    assert_equal answer.a1, 'name3'
  end

  test "если значения из harvest разбиты на несколько строк" do
    pollens = [
      %w(id name sugar_per_mg),
      ['1', 'name1', '10'],
      ['2', 'name2', '1'],
      ['3', 'name3', '5']
    ]

    harvest = [
      %w(bee_id day pollen_id miligrams_harvested),
      ['1', '2013-04-01', '2', '1'],
      ['1', '2013-04-01', '2', '9'],
      ['2', '2013-05-01', '1', '1.5'],
      ['3', '2013-04-07', '3', '2'],
      ['1', '2013-04-01', '2', '4'],
      ['1', '2013-04-01', '2', '6'],
      ['3', '2013-04-07', '3', '4'],
      ['3', '2013-04-07', '3', '1']
    ]
    
    answer = Answer.new(harvest: harvest, pollens: pollens)

    assert_equal answer.a1, 'name3'
  end

  test "если максимальных несколько, то вернем любой" do
    pollens = [
      %w(id name sugar_per_mg),
      ['1', 'name1', '10'],
      ['2', 'name2', '1'],
      ['3', 'name3', '5']
    ]

    harvest = [
      %w(bee_id day pollen_id miligrams_harvested),
      ['2', '2013-05-01', '1', '5'],  # 45
      ['3', '2013-04-07', '3', '10'], # 50
      ['1', '2013-04-01', '2', '45']  # 50
    ]
    
    answer = Answer.new(harvest: harvest, pollens: pollens)

    assert_includes ['name1', 'name3'], answer.a1
  end

  # Какая пыльца была наиболее популярна среди пчел
  test "одна пчела собирала разные виды пыльцы" do
    pollens = [
      %w(id name sugar_per_mg),
      ['1', 'name1', '10'],
      ['2', 'name2', '1'],
      ['3', 'name3', '5']
    ]

    harvest = [
      %w(bee_id day pollen_id miligrams_harvested),
      ['1', '2013-04-01', '2', '20'],
      ['1', '2013-05-01', '1', '1.5'],
      ['1', '2013-04-07', '3', '7']
    ]

    answer = Answer.new(harvest: harvest, pollens: pollens)

    assert_equal answer.a2, 'name2'
  end

  test "несколько пчел собирали пыльцу. Проверим что учитывается без учета пчел" do
    pollens = [
      %w(id name sugar_per_mg),
      ['1', 'name1', '10'],
      ['2', 'name2', '1'],
      ['3', 'name3', '5']
    ]

    harvest = [
      %w(bee_id day pollen_id miligrams_harvested),
      ['1', '2013-04-01', '2', '20'],
      ['1', '2013-05-01', '1', '1.5'],
      ['2', '2013-04-07', '3', '7'],
      ['1', '2013-03-01', '2', '1'],
      ['1', '2013-05-05', '1', '15'],
      ['3', '2013-04-08', '3', '17']
    ]

    answer = Answer.new(harvest: harvest, pollens: pollens)

    assert_equal answer.a2, 'name3'
  end

  test "несколько пчел собирали пыльцу. Разобьем по дням. Проверим что учитывается без учета пчел" do
    pollens = [
      %w(id name sugar_per_mg),
      ['1', 'name1', '10'],
      ['2', 'name2', '1'],
      ['3', 'name3', '5']
    ]

    harvest = [
      %w(bee_id day pollen_id miligrams_harvested),
      ['1', '2013-04-01', '2', '18'],
      ['1', '2013-04-05', '2', '2'],
      ['1', '2013-05-02', '1', '0.5'],
      ['1', '2013-05-01', '1', '1'],
      ['2', '2013-04-05', '3', '3'],
      ['2', '2013-04-07', '3', '4'],
      ['1', '2013-03-01', '2', '1'],
      ['1', '2013-05-05', '1', '15'],
      ['3', '2013-04-08', '3', '13'],
      ['3', '2013-04-09', '3', '14']
    ]

    answer = Answer.new(harvest: harvest, pollens: pollens)

    assert_equal answer.a2, 'name3'
  end

  test "если несколько одинаковых вариантов, то вернется любой" do
    pollens = [
      %w(id name sugar_per_mg),
      ['1', 'name1', '10'],
      ['2', 'name2', '1'],
      ['3', 'name3', '5']
    ]

    harvest = [
      %w(bee_id day pollen_id miligrams_harvested),
      ['1', '2013-04-01', '2', '20'],
      ['1', '2013-05-01', '1', '1.5'],
      ['1', '2013-04-07', '3', '20']
    ]

    answer = Answer.new(harvest: harvest, pollens: pollens)

    assert_includes ['name2', 'name3'], answer.a2
  end

  # Какой день был самым лучшим для сбора урожая? Какой был худшим?
  # Статистика общая по дням
  test "Проверим количество сахара за каждый день" do
    pollens = [
      %w(id name sugar_per_mg),
      ['1', 'name1', '10'],
      ['2', 'name2', '1'],
      ['3', 'name3', '5']
    ]

    harvest = [
      %w(bee_id day pollen_id miligrams_harvested),
      ['1', '2013-04-01', '2', '20'],  # 20
      ['2', '2013-04-01', '1', '20'],  # 200
      ['2', '2013-05-01', '1', '1.5'], # 15
      ['1', '2013-04-07', '3', '20']   # 100
    ]

    answer = Answer.new(harvest: harvest, pollens: pollens)

    assert_equal answer.stat_by_days, [['2013-04-01', 220.0], ['2013-04-07', 100.0], ['2013-05-01', 15.0]]
  end

  # Посмотрим результат: худший и лучший день
  test "худший и лучший день" do
    pollens = [
      %w(id name sugar_per_mg),
      ['1', 'name1', '10'],
      ['2', 'name2', '1'],
      ['3', 'name3', '5']
    ]

    harvest = [
      %w(bee_id day pollen_id miligrams_harvested),
      ['1', '2013-04-01', '2', '20'],  # 20
      ['2', '2013-04-01', '1', '20'],  # 200
      ['2', '2013-05-01', '1', '1.5'], # 15
      ['1', '2013-04-07', '3', '20']   # 100
    ]

    answer = Answer.new(harvest: harvest, pollens: pollens)

    assert_equal answer.best_and_worst_day, {best: '2013-04-01', worst: '2013-05-01'}
  end

  # Какая пчела была наиболее эффективной? Какая была наименее эффективной? Эффективность измеряется как среднее количество сахара за все рабочие дни (Было бы здорово увидеть таблицу для всех пчел)
  # Статистика общая по пчелам
  test "проверим, что группировка происходит по пчелам" do
    pollens = [
      %w(id name sugar_per_mg),
      ['1', 'name1', '10'],
      ['2', 'name2', '1'],
      ['3', 'name3', '5']
    ]

    harvest = [
      %w(bee_id day pollen_id miligrams_harvested),
      ['1', '2013-04-01', '2', '20'],  # 20
      ['3', '2013-05-01', '1', '1.5'],  # 15
      ['2', '2013-04-02', '1', '20']  # 200
    ]

    answer = Answer.new(harvest: harvest, pollens: pollens)

    assert_equal answer.stat_by_bee, [[1, 20.0], [2, 200.0], [3, 15.0]]
  end

  test "проверим, если для пчелы 1 есть несколько записей в день" do
    pollens = [
      %w(id name sugar_per_mg),
      ['1', 'name1', '10'],
      ['2', 'name2', '1'],
      ['3', 'name3', '5']
    ]

    harvest = [
      %w(bee_id day pollen_id miligrams_harvested),
      ['1', '2013-04-01', '2', '20'],  # 20
      ['3', '2013-05-01', '1', '1.5'],  # 15
      ['1', '2013-04-01', '1', '20'],  # 200
      ['2', '2013-04-02', '1', '20']  # 200
    ]

    answer = Answer.new(harvest: harvest, pollens: pollens)

    assert_equal answer.stat_by_bee, [[1, 220.0], [2, 200.0], [3, 15.0]]
  end

  test "проверим, если для пчелы есть несколько дней" do
    pollens = [
      %w(id name sugar_per_mg),
      ['1', 'name1', '10'],
      ['2', 'name2', '1'],
      ['3', 'name3', '5']
    ]

    harvest = [
      %w(bee_id day pollen_id miligrams_harvested),
      ['1', '2013-04-01', '2', '20'],  # 20
      ['1', '2013-04-03', '1', '20'],  # 200
      ['3', '2013-05-01', '1', '1.5'],  # 15
      ['2', '2013-04-02', '1', '10'],  # 100
      ['2', '2013-04-03', '1', '10']  # 100
    ]

    answer = Answer.new(harvest: harvest, pollens: pollens)

    assert_equal answer.stat_by_bee, [[1, 110.0], [2, 100.0], [3, 15.0]]
  end

  # Посмотрим результат: худшая и лучшая пчела
  test "лучшая и худшая пчела" do
    pollens = [
      %w(id name sugar_per_mg),
      ['1', 'name1', '10'],
      ['2', 'name2', '1'],
      ['3', 'name3', '5']
    ]

    harvest = [
      %w(bee_id day pollen_id miligrams_harvested),
      ['1', '2013-04-01', '2', '20'],  # 20
      ['1', '2013-04-03', '1', '20'],  # 200
      ['2', '2013-04-02', '1', '10'],  # 100
      ['2', '2013-04-03', '1', '10'],  # 100
      ['3', '2013-05-01', '1', '1.5']  # 15
    ]

    answer = Answer.new(harvest: harvest, pollens: pollens)

    assert_equal answer.best_and_worst_bee, {best: 1, worst: 3}
  end

end
