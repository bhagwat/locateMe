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
//			initializeMap();
			var e = document.createElement('script');
			e.async = true;
			e.src = document.location.protocol + '//connect.facebook.net/en_US/all.js';
			document.getElementById('fb-root').appendChild(e);
		});
		geocoder = new google.maps.Geocoder();
		function updateHomeLocation(event, data) {
			googleMap.fitBounds(data.geometry.bounds);
		}
	</script>
	<g:javascript src="findme.facebook-3.js"/>
</head>
<body style="margin:5px;">
<div id="fb-root" style="display:none"></div>
<div id="login-flow">
	<fb:login-button perms="${permissions}" show-faces="true"></fb:login-button>
</div>
<table>
	<tr>
		<td>
			<h2>
				<a href="${createLink(action: 'userInfo', id: loggedInUserId)}">
					${userInfo.name}
					(<g:message code="go.back.to.home" default="Go Back to Home"/>)
				</a>
			</h2>
		</td>
		<td>
			<div class="navigation">
				<a href="javascript:;" onclick="showFriendsOnMapByHomeLocation();"><g:message code="show.by.home.location" default="Show by home location"/></a>
				<a href="javascript:;" onclick="showFriendsOnMapByCurrentLocation();"><g:message code="show.by.current.location" default="Show by current location"/></a>
			</div>
		</td>
	</tr>
	<tr>
		<td>
			Search : <googleMap:searchAddressInput onComplete="updateHomeLocation" name="searchAddress"
				map="googleMap" width="450" minChars="3" scrollHeight="420" style="width:80%;"/> <br/>
			<googleMap:map
				name="googleMap"
				mapDivId="map_canvas"
				zoom="18"
				homeMarker="[latitude: 40.729883, longitude: -73.990986, draggable: false, visible:false, content: 'Liberty State Park']"
				mapTypeId="google.maps.MapTypeId.ROADMAP"/>
			<div id="map_canvas" style="width: 600px; height: 410px;"></div>
		</td>
		<td>
			<div id="friend-count"></div>
			<div style="width: 600px; height: 400px;overflow:auto;">
				<table id="friendList" cellpadding="1" cellspacing="1">
					<thead>
					<tr style="width:60%;">
						<th><g:message code="user.name" default="Name"/></th>
						<th><g:message code="user.gender" default="Gender"/></th>
						<th><g:message code="user.birthday" default="Birthday"/></th>
						<th><g:message code="user.hometown" default="Hometown"/></th>
						<th><g:message code="user.current.location" default="Current Location"/></th>
						<th><g:message code="user.online" default="Online"/></th>
						<th><g:message code="user.picture" default="Picture"/></th>
					</tr>
					</thead>
				</table>
			</div>
		</td>
	</tr>
</table>
</body>
</html>
