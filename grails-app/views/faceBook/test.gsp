<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
	<meta name="layout" content="main"/>
	<title>JavaScript SDK test</title>
</head>
<body>
<div id="fb-root"></div>
<script src="http://connect.facebook.net/en_US/all.js"></script>
<script>
	var currentUserId = "${loggedInUserId}";
	FB.init({
		appId: '186418821373054',
		status: true,
		cookie: true,
		xfbml: true,
		channelUrl  : "${grailsApplication.config.grails.serverURL}/channel.html"  // custom channel
	});
	FB.api(
	{
		method: "fql.query",
		query: "SELECT uid, name,sex, pic_small, birthday, hometown_location, current_location FROM user WHERE uid = " + currentUserId +
			" OR uid IN (SELECT uid2 FROM friend WHERE uid1 =" + currentUserId + ")"
	}, function(response) {
			console.debug(response)
		}
		);

	function postOnWall(msg) {
		FB.ui(
		{
			method: 'feed',
			name: 'Bhagwat Status',
			link: 'http://developers.facebook.com/docs/reference/dialogs/',
			caption: 'Reference Documentation',
			description: 'Dialogs provide a simple, consistent interface for applications to interface with users.',
			message: 'Facebook Dialogs are easy!'
		},
			function(response) {
				if (response && response.post_id) {
					alert('Post was published.');
				} else {
					alert('Post was not published.');
				}
			}
			)
	}

</script>
<button onclick="postOnWall('hello from here')" value="Click"/>
</body>
</html>