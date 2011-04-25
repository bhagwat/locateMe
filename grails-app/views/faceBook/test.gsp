<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
	<meta name="layout" content="main" />
	<title>JavaScript SDK test</title>
</head>
<body>

<div id="fb-root"></div>
<script type="text/javascript">
	var graphURL = "${urlFriendsList}";

	window.fbAsyncInit = function() {
		FB.init({appId: '186418821373054', status: true, cookie: true,
			xfbml: true});
		FB.api(
		{
			method: 'fql.query',
			query: 'SELECT name FROM user WHERE uid=100000475647222'
		},
			function(response) {
				jQuery('#userDetail').html(response[0].name);
			}
			);
//		testQuery();
	};
	function postOnWall() {
		FB.ui(
		{
			method: 'feed',
			name: 'Mukesh Status',
			link: 'http://developers.facebook.com/docs/reference/dialogs/',
			picture: 'http://facebook-google-map.appspot.com/images/mukesh.jpg',
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
			);
	}
	function loadPosts() {
		var script = document.createElement("script");
		script.src = graphURL;
		document.body.appendChild(script);
	}

	function processResult(posts) {
		if (posts.paging == undefined) {
			document.getElementById("loadMore").innerHTML =
				"No more results";
		}
		else {
			graphURL = posts.paging.next;
			for (var post in posts.data) {
				jQuery('#content ul').append("<li style='border:1px solid gray;list-style:none;'><div>"+
					posts.data[post].id+"<br/>"+
					posts.data[post].name+"<br/>"+
					posts.data[post].gender+"<br/>"+
					"<img src='"+posts.data[post].picture+"/><br/>"+
					"<a target='_blank' href='"+posts.data[post].link+"'>Profile page</a><br/>"+
					"</div></li>");
			}
			console.debug(posts);
			loadPosts();
		}
	}

	function testQuery() {
		// First, get ten of the logged-in user's friends and the events they
		// are attending. In this query, the argument is just an int value
		// (the logged-in user id). Note, we are not firing the query yet.
		var user_id = 100000475647222;
		var query = FB.Data.query(
			"select uid, eid from event_member "
				+ "where uid in "
				+ "(select uid2 from friend where uid1 = {0}"
				+ " order by rand() limit 10)",
			user_id);

		// Now, construct two dependent queries - one each to get the
		// names of the friends and the events referenced
		var friends = FB.Data.query(
			"select uid, name from user where uid in "
				+ "(select uid from {0})", query);
		var events = FB.Data.query(
			"select eid, name from event where eid in "
				+ " (select eid from {0})", query);

		// Now, register a callback which will execute once all three
		// queries return with data
		FB.Data.waitOn([query, friends, events], function() {
			// build a map of eid, uid to name
			var eventNames = friendNames = {};
			FB.Array.forEach(events.value, function(row) {
				eventNames[row.eid] = row.name;
			});
			FB.Array.forEach(friends.value, function(row) {
				friendNames[row.uid] = row.name;
			});

			// now display all the results
			var html = '';
			FB.Array.forEach(query.value, function(row) {
				html += '<p>'
					+ friendNames[row.uid]
					+ ' is attending '
					+ eventNames[row.eid]
					+ '</p>';
			});
			document.getElementById('display').innerHTML = html;
		});

	}
	function postMessage(message) {
		FB.ui(
		{
			method: 'feed',
			attachment: {
				name: 'JSSDK',
				caption: 'The Facebook JavaScript SDK',
				description: (
					'A small JavaScript library that allows you to harness ' +
						'the power of Facebook, bringing the user\'s identity, ' +
						'social graph and distribution power to your site.'
					),
				href: 'http://fbrell.com/'
			},
			action_links: [
				{ text: 'fbrell', href: 'http://fbrell.com/' }
			]
		},
			function(response) {
				if (response && response.post_id) {
					alert('Post was published.');
				} else {
					alert('Post was not published.');
				}
			}
			);
	}
	(function() {
		var e = document.createElement('script');
		e.async = true;
		e.src = document.location.protocol +
			'//connect.facebook.net/en_US/all.js';
		document.getElementById('fb-root').appendChild(e);
	}());
	jQuery(document).ready(function(){loadPosts();})
</script>
<div id="userDetail">

</div>
<div id="display">

</div>
<div id="login-flow">
	<fb:login-button perms="email,offline_access" show-faces="true"></fb:login-button>
</div>
%{--
<fb:registration
  fields="name,birthday,gender,location,email"
  redirect-uri="${createLink(absolute:true, action:'register')}"
  width="530">
</fb:registration>
--}%
<div id="content">
	<ul>
	</ul>
</div>
<button id="loadMore" onclick="loadPosts()">Load more</button>

</body>
</html>