<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
	<meta name="layout" content="main"/>
	<title><g:message code="where.are.your.friends" default="Where are your friends?"/></title>
	<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
	<script type="text/javascript">
		var applicationID = "${applicationID}";
		var currentUserId = "${loggedInUserId}";
		var applicationRoot = "${grailsApplication.config.grails.serverURL}/faceBook/userInfo/";
		jQuery(document).ready(function() {
			initializeMap();
			var e = document.createElement('script');
			e.async = true;
			e.src = document.location.protocol + '//connect.facebook.net/en_US/all.js';
			document.getElementById('fb-root').appendChild(e);
		});
	</script>
	<g:javascript src="findme.facebook.js"/>
</head>
<body style="margin:5px;">

<div id="fb-root" style="display:none"></div>
<div id="login-flow">
	<fb:login-button perms="${permissions}" show-faces="true"></fb:login-button>
</div>
<table>
	<tr>
		<td colspan="2">
			<h2><a href="${createLink(action: 'userInfo', id: loggedInUserId)}">${userInfo.name}(<g:message code="go.back.to.home" default="Go Back to Home"/>)</a></h2>
		</td>
	</tr>
	<tr>
		<td>
			<div id="map_canvas" style="width: 600px; height: 410px;"></div>
		</td>
		<td>
			<div id="friend-count"></div>
			<div style="width: 600px; height: 400px;overflow:auto;">
				<table id="friendList" cellpadding="1" cellspacing="1">
					<thead>
					<tr style="width:60%;">
						<th>Name</th>
						<th>Gender</th>
						<th>Birthday</th>
						<th>Hometown</th>
						<th>Current Location</th>
						<th>Online Status</th>
						<th>picture</th>
					</tr>
					</thead>
				</table>
			</div>
		</td>
	</tr>
</table>
</body>
</html>
