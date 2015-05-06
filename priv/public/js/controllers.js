var app = angular.module('r5bApp', ['ui.bootstrap']);

app.factory('r5bHomePageService', function ($http) {
	return {

		getMoreTopNewsWithImages: function (Category, count, skip) {
			return $http.get('/api/news/topnews_with_images?c=' + Category + '&n=' + count + '&s=' + skip).then(function (result) {
				// return result.data.rows;
				return result.data.articles;
			});
		},

	};
});
app.controller('R5bHome', function ($scope, r5bHomePageService) {
	//the clean and simple way
	
	$scope.topSportsNews = r5bHomePageService.getMoreTopNewsWithImages('text_us_sports',5,3);
	$scope.topNbaNews = r5bHomePageService.getMoreTopNewsWithImages('text_us_nba',5,0);
	$scope.topNflNews = r5bHomePageService.getMoreTopNewsWithImages('text_us_nfl',5,0);
	$scope.topNhlNews = r5bHomePageService.getMoreTopNewsWithImages('text_us_nhl',5,0);
	$scope.topNewsWithImages = r5bHomePageService.getMoreTopNewsWithImages('text_top_us_sports',3,0);
	$scope.currentYear = (new Date).getFullYear();

	// Get all Video's Count
	$scope.newsPerPage = 12;
  	$scope.newsCount = 150;

  // Generate the numberOfPages and pages content based on the videoCount
  $scope.$watch('newsCount', function (newsCount) {
    if (newsCount !== undefined) {
      // Sample Output: {"rows":[{"key":null,"value":650}]}
      $scope.numberOfPages = (Math.ceil(newsCount/$scope.newsPerPage)).toString();

      // Pagination plugin
      $scope.bigTotalItems = newsCount;
    }
  });

  // Javascript Custom Function to get teh URL params, decode them
  function getURLParameter (name) {
    return decodeURIComponent((new RegExp('[?|&]' + name + '=' + '([^&;]+?)(&|#|;|$)').exec(location.search)||[,""])[1].replace(/\+/g, '%20'))||null;
  }

  // Get noneFeaturedVideos list based on the page(number) we are hitting from.
  $scope.currentPageNumber = parseInt(getURLParameter('p'), 10);
  
  if (isNaN($scope.currentPageNumber)) {
    skipValue = 0;
    $scope.currentPageNumber = 1;
  } else {
    skipValue = parseInt(($scope.currentPageNumber - 1) * $scope.videosPerPage, 10);
  }

  // Pagination plugin
  $scope.bigCurrentPage = $scope.currentPageNumber;
  $scope.maxSize = 6; // Max number of pages to be displayed at a time


  // Pagination plugin
  // This function is triggred when user tends to change the page using the plugin.
  $scope.pageChanged = function (page) {
    location.replace('/morevideos?p=' + page);
  };
});

