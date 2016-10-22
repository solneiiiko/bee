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
function statisticShow (index,$container) {
	console.log($container);
	console.log(statisticData);
};
