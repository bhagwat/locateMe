var googleMap;
var geoCoder;
var applicationID;
var currentUserId;
var regionWiseUsers = new Object();
function getRegionString(address) {
		return address ? address.city + " " + address.state + " " + address.country : 'No address';
}
function addToState(userItem) {
		var regionString = getRegionString(userItem.hometown_location);
		if (!regionWiseUsers[regionString]) {
				regionWiseUsers[regionString] = new Object();
				regionWiseUsers[regionString].name = regionString;
				regionWiseUsers[regionString].users = new Array();
		}
		regionWiseUsers[regionString].users.push(userItem);
}
function addUserDetailToTable(userItem) {
		friendId = userItem.uid;
		friendName = userItem.name;
		friendGender = userItem.sex;
		friendBirthday = userItem.birthday;
		hometown = getRegionString(userItem.hometown_location);
		currentLocation = getRegionString(userItem.current_location);
		friendLink = "";
		friendPicture = userItem.pic_square;
		friendOnline = userItem.online_presence || '';
		jQuery('#friendList').append(friendTdFbApi(friendId, friendName, friendGender, friendBirthday, hometown, currentLocation, friendLink, friendPicture, friendOnline));
}
function getHeaderHtml(text) {
		return "<tr><td colspan='7'><h3>" + text + "</h3></td></tr>";
}
function getRegionHeaderHtml(regionItem) {
		return getHeaderHtml(regionItem.name + " (Total: " + regionItem.users.length + " Friends)");
}

function friendTdFbApi(friendId, friendName, friendGender, friendBirthday, hometown, currentLocation, friendLink, friendPicture, friendOnline) {
		return	 "<tr style='width:40%'>" +
				"<td><a href='" + applicationRoot + "'" + friendId + "'>" + friendName + "</a></td>" +
				"<td>" + friendGender + "</td>" +
				"<td>" + friendBirthday + "</td>" +
				"<td>" + hometown + "</td>" +
				"<td>" + currentLocation + "</td>" +
				"<td>" + friendOnline + "</td>" +
				"<td><a href='" + applicationRoot + "'" + friendId + "'><img src='" + friendPicture + "' alt='" + friendName + " Picture'/></a></td>" +
				"</tr>";

}
window.fbAsyncInit = function() {
		FB.init({appId: applicationID, status: true, cookie: true,
				xfbml: true});
		FB.api(
		{
				method: "fql.query",
				query: "SELECT uid, name,sex, pic_square, birthday, hometown_location, current_location,online_presence FROM user WHERE uid = " + currentUserId +
						" OR uid IN (SELECT uid2 FROM friend WHERE uid1 =" + currentUserId + ")"
		},
				function(response) {
						if (response.error_msg) {
								jQuery('#friendList').append(getHeaderHtml(response.error_msg));
								return;
						}
						var friendId, friendName, friendGender,friendBirthday, hometown, currentLocation, friendLink, friendPicture;
						jQuery(response).each(function() {
								addToState(this)
						});
						for (var index in regionWiseUsers) {
								jQuery('#friendList').append(getRegionHeaderHtml(regionWiseUsers[index]));
								var popupHtml = "<div style='height:210px; width:200px'><h3>" + regionWiseUsers[index].name + "</h3><br/><ul>";
								jQuery(regionWiseUsers[index].users).each(function(key, userItem) {
										addUserDetailToTable(userItem)
										popupHtml += "<li style='list-style:none;'>" +
												"<a href='" + applicationRoot + "'" + userItem.uid + "'><img src='" + userItem.pic_square + "' alt='" + userItem.name + " Picture'/></a>" + userItem.name +
												"</li>";
								});
								popupHtml += "</div></ul>";
								searchAddress(regionWiseUsers[index].name, popupHtml);
						}
				})
};

function initializeMap() {
		var myLatlng = new google.maps.LatLng(-34.397, 150.644);
		var myOptions = {
				zoom: 8,
				center: myLatlng,
				mapTypeId: google.maps.MapTypeId.ROADMAP
		};
		googleMap = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
		geocoder = new google.maps.Geocoder();
}
function searchAddress(address, content) {
		if (address.length && geocoder) {
				geocoder.geocode({ 'address': address}, function(results, status) {
						if (status == google.maps.GeocoderStatus.OK) {
//						var content = jQuery("#userDetail").html();
								createMarkerAndInfoWindowForLocation(results[0].geometry.location, content, googleMap);
						}
				});
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
}