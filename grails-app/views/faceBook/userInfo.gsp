<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
	<meta name="layout" content="main"/>
	<title><g:message code="where.are.your.friends" default="Where are your friends?"/></title>
	<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
	<style type="text/css">
	.horizontal li {
		display: inline;
		list-style-type: none;
		padding-right: 20px;
		line-height: 20px;
	}

	.head {
		margin: 7px 0;
	}

	.hidden {
		display: none;
	}
	</style>
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
		geocoder = getGeoCoder();

	</script>
	<g:javascript src="findme.facebook-4.js"/>
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
				<input type="button" onclick="showFriendsOnMapByHomeLocation();" value="${message(code: 'show.by.home.location')}"/>
				<input type="button" onclick="showFriendsOnMapByCurrentLocation();" value="${message(code: 'show.by.current.location')}"/>
				<input type="button" onclick="$('#friendList .head').next().hide();" value="${message(code: 'collapse.all')}"/>
				<input type="button" onclick="$('#friendList .head').next().show();" value="${message(code: 'expand.all')}"/>
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
			<div id="friendList" style="width: 600px; height: 400px;overflow:auto;">

			</div>
		</td>
	</tr>
</table>
</body>
</html>
