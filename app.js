var App = angular.module('App', []);

App.controller('FlyersCtrl', function($scope, $http) {
	$scope.iframeHeight = window.innerHeight;
	// $scope.iframeWidth = window.innerWidth;

  $http.get('photos.json')
	.then(function(res){
		angular.forEach(res.data.photos.data, function(value, key) {
			value.images = value.images[0].source;
		});
		$scope.photos = res.data.photos.data;
	});
});