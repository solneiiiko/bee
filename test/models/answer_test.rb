#coding: utf-8
require 'test_helper'

class AnswerTest < ActiveSupport::TestCase
  
  %i(a1 a2 a3 a4).each do |method_name|
    test "#{method_name} с пустыми данными" do
      answer = Answer.new(harvest: [], pollens: [])
      assert_equal answer.method(method_name).call, []    
    end
  end

  #Из пыльцы какого типа было получено больше всего сахара: a1
  test "действительно ли значение считаем с двух таблиц, а не берем самое большое в какой-то" do
    pollens = [
      %w(id name sugar_per_mg),
      [1, 'name1', 10],
      [2, 'name2', 1],
      [3, 'name3', 5]
    ]

    harvest = [
      %w(bee_id day pollen_id miligrams_harvested),
      [1, '2013-04-01', 2, 20],  # 20
      [2, '2013-05-01', 1, 1.5], # 15
      [3, '2013-04-07', 3, 7]    # 35
    ]

    answer = Answer.new(harvest: harvest, pollens: pollens)

    assert_equal answer.a1, 'name3'
  end

  test "если значения из harvest разбиты на несколько строк" do
    pollens = [
      %w(id name sugar_per_mg),
      [1, 'name1', 10],
      [2, 'name2', 1],
      [3, 'name3', 5]
    ]

    harvest = [
      %w(bee_id day pollen_id miligrams_harvested),
      [1, '2013-04-01', 2, 1],
      [1, '2013-04-01', 2, 9],
      [2, '2013-05-01', 1, 1.5],
      [3, '2013-04-07', 3, 2],
      [1, '2013-04-01', 2, 4],
      [1, '2013-04-01', 2, 6],
      [3, '2013-04-07', 3, 4],
      [3, '2013-04-07', 3, 1]
    ]
    
    answer = Answer.new(harvest: harvest, pollens: pollens)

    assert_equal answer.a1, 'name3'
  end

  test "если максимальных несколько, то вернем минимальный по id" do
    pollens = [
      %w(id name sugar_per_mg),
      [1, 'name1', 10],
      [2, 'name2', 1],
      [3, 'name3', 5]
    ]

    harvest = [
      %w(bee_id day pollen_id miligrams_harvested),
      [1, '2013-04-01', 2, 45], # 50
      [2, '2013-05-01', 1, 5],  # 45
      [3, '2013-04-07', 3, 10]  # 50
    ]
    
    answer = Answer.new(harvest: harvest, pollens: pollens)

    assert_equal answer.a1, 'name1'
  end

  #a2
  test "2" do
    assert false
  end

  #a3
  test "3" do
    assert false
  end

  #a4
  test "4" do
    assert false
  end

end
