<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8"/>
	<meta name="layout" content="main"/>
	<title>Where are you?</title>
	<script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
	<script type="text/javascript">
		var googleMap;
		var geoCoder;
		var graphURL = "${urlFriendsList}";
		var friendCount=0;
		function initializeMap() {
			var myLatlng = new google.maps.LatLng(-34.397, 150.644);
			var myOptions = {
				zoom: 8,
				center: myLatlng,
				mapTypeId: google.maps.MapTypeId.ROADMAP
			};
			googleMap = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
			geocoder = new google.maps.Geocoder();
			searchAddress("${userInfo.hometown?.name}")
		}
		function searchAddress(address) {
			if (address.length && geocoder) {
				geocoder.geocode({ 'address': address}, function(results, status) {
					if (status == google.maps.GeocoderStatus.OK) {
						var content = jQuery("#userDetail").html();
						createMarkerAndInfoWindowForLocation(results[0].geometry.location, content, googleMap);
					} else {
						jQuery("#address-not-found").show();
						jQuery("#userDetail").show();
					}
				});
			} else {
				jQuery("#address-not-found").show();
				jQuery("#userDetail").show();
			}
			return false;
		}
		function createMarkerAndInfoWindowForLocation(location, content, map, icon) {
			if (!map) {
				map = googleMap;
			}
			var marker = new google.maps.Marker({map: map, position: location});
			if (icon && icon.length) {
				marker.setIcon(icon);
			}
			var infoWindow = new google.maps.InfoWindow({
				content:content,
				size: new google.maps.Size(100, 150)
			});
			google.maps.event.addListener(marker, 'click', function() {
				infoWindow.open(map, marker);
			});
			googleMap.setCenter(marker.getPosition());
			infoWindow.close();
			infoWindow.open(map, marker);
		}

		window.fbAsyncInit = function() {
			FB.init({appId: ${applicationID}, status: true, cookie: true,xfbml: true});
		};
		jQuery(document).ready(function() {
			initializeMap();
			var e = document.createElement('script');
			e.async = true;
			e.src = document.location.protocol + '//connect.facebook.net/en_US/all.js';
			document.getElementById('fb-root').appendChild(e);
			loadPosts();
		});


		function friendTd(friendId, friendName, friendGender, friendLink, friendPicture) {
			return	 "<tr style='width:40%'><td><a href='${grailsApplication.config.grails.serverURL}/faceBook/userInfo/" + friendId + "'>" + friendName + "</a></td><td>" + friendGender + "</td><td><a href='" + friendLink + "'><img src='" + friendPicture + "' alt='" + friendName + " Picture'/></a></td></tr>";

		}
		function loadPosts() {
			var script = document.createElement("script");
			script.src = graphURL;
			document.body.appendChild(script);
		}

		function processResult(posts) {
			console.debug(posts)
			if (!posts.paging || posts.paging == undefined) {
				jQuery("#friend-count").html("<strong>Displaying total "+friendCount+" friend(s).</strong>")
			}
			else {
				graphURL = posts.paging.next;
				for (var post in posts.data) {
					friendCount++;
					var friend = posts.data[post];
					jQuery('#friendList').append(friendTd(friend.id, friend.name, friend.gender, friend.link, friend.picture));
				}
				loadPosts();
			}
		}

	</script>
</head>
<body style="margin:5px;">
<h2><a href="${createLink(action: 'userInfo', id: loggedInUserIdWelcome)}">${userInfo.name}(Go Back to Home)</a></h2>
<div id="fb-root" style="display:none"></div>
<div id="login-flow">
	<fb:login-button perms="${permissions}" show-faces="true"></fb:login-button>
</div>
<table>
	<tr>
		<td colspan="2">
			<div id="address-not-found" style="display:none">We are unable to find your location. Possible cause : You have not set your home location correctly</div>
		</td>
	</tr>
	<tr>
		<td>
			<div id="map_canvas" style="width: 650px; height: 410px;"></div>
		</td>
		<td>
			<div id="friend-count"></div>
			<div style="width: 550px; height: 400px;overflow:auto;">
				<table id="friendList" cellpadding="1" cellspacing="1">
					<thead>
					<tr style="width:60%;">
						<th>Name</th>
						<th>Gender</th>
						<th>picture</th>
					</tr>
					</thead>
				</table>
			</div>
		</td>
	</tr>
</table>
<g:if test="${userInfo}">
	<div id="userDetail" class="dialog" style="display:none">
		<table border="none">
			<tr>
				<td colspan="2" valign="center" align="center">
					<a target="_blank" href="${userInfo.link}">
						<strong>${userInfo.name}</strong>
						<img alt="${userInfo.name}" src="http://graph.facebook.com/${userInfo.username}/picture"/>
					</a>
				</td>
			</tr>
			<tr>
				<td>Gender</td>
				<td>${userInfo.gender}</td>
			</tr>
			<tr>
				<td>Birth Date</td>
				<td>${userInfo.birthday}</td>
			</tr>
			<tr>
				<td>Home Town</td>
				<td>${userInfo.hometown?.name}</td>
			</tr>
			<tr>
				<td>Current Location</td>
				<td>${userInfo.location?.name}</td>
			</tr>
			<tr>
				<td>Website</td>
				<td><a target="_blank" href="${userInfo.website}">${userInfo.website}</a></td>
			</tr>
		</table>
	</div>
</g:if>

</body>
</html>