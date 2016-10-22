'use strict'

var statisticData;

$(document).ready(function () {
	$.ajax({
		url: '/statistic/',
		dataType: 'json',
		success: function(data){
			statisticData = data;
			$('[data-statistic]').each(statisticShow);
		}
	});

});

/**
* Отрисовка статистики в  виде диаграммы
*/
function statisticShow (index,container) {
	var $container = $(container),
		key = $container.attr('data-statistic');

	//Chart.js будем использовать
	//построим данные
	var color = statisticData[key].map(function (vals) { return [parseInt(getRandom(1, 255)), parseInt(getRandom(1, 255)), parseInt(getRandom(1, 255))].join();}),
		dataChart = {
		    labels: statisticData[key].map(function (vals) { return vals[0] }),// bee_id или day
		    datasets: [
		        {
		            label: "",
		            backgroundColor: color.map(function (vals) { return 'rgba(' + vals + ',0.2)'; }),
		            borderColor: color.map(function (vals) { return 'rgba(' + vals + ',1)'; }),
		            borderWidth: 1,
		            data: statisticData[key].map(function (vals) { return vals[1] }), // посчитанное значение
		        }
		    ]
		};
	var barChart = new Chart($container, {
		type: 'bar',
		data: dataChart,
		options: {}
	});


	console.log(statisticData[key]);
};

function getRandom (min, max) {
  return Math.random() * (max - min) + min;
};

