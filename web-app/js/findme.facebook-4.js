var googleMap;
var geoCoder;
var applicationID;
var currentUserId;
var regionWiseUsers = new Object();
var friendList;
var mapMarkerAndInfoWindows = new Array();
var noAddress = "No Address";
var cachedAddress = new Array();
function findAddressFromCache(address) {
		jQuery(cachedAddress).each(function() {
				if (this.address == address) {
						return this.position;
				}
		});
		return null;
}
function clearMap() {
		jQuery(mapMarkerAndInfoWindows).each(function() {
				if (this.marker) this.marker.setMap(null);
				if (this.infoWindow) this.infoWindow = null;
		});
		mapMarkerAndInfoWindows = new Array();
}
function getRegionString(address) {
		return address ? address.city + " " + address.state + " " + address.country : noAddress;
}
function addToState(userItem, regionString) {
		if (!regionWiseUsers[regionString]) {
				regionWiseUsers[regionString] = new Object();
				regionWiseUsers[regionString].name = regionString;
				regionWiseUsers[regionString].users = new Array();
		}
		regionWiseUsers[regionString].users.push(userItem);
}
function getUserDetailListHtml(userItem) {
		var friendId, friendName, friendGender,friendBirthday, hometown, currentLocation, friendLink, friendPicture,friendOnline;
		friendId = userItem.uid;
		friendName = userItem.name;
		friendGender = userItem.sex;
		friendBirthday = userItem.birthday;
		hometown = getRegionString(userItem.hometown_location);
		currentLocation = getRegionString(userItem.current_location);
		friendLink = "";
		friendPicture = userItem.pic_small;
		friendOnline = userItem.online_presence ? userItem.online_presence : '';
//				jQuery('#friendList').append(friendTdFbApi(friendId, friendName, friendGender, friendBirthday, hometown, currentLocation, friendLink, friendPicture, friendOnline));
		return friendTdFbApi(friendId, friendName, friendGender, friendBirthday, hometown, currentLocation, friendLink, friendPicture, friendOnline);
}
function getHeaderHtml(text) {
		return "<h3 class='head'><a href='#'>" + text + "</a></h3>";
}
function getRegionHeaderHtml(regionItem) {
		return getHeaderHtml(regionItem.name + " (Total: " + regionItem.users.length + " Friends)");
}

function friendTdFbApi(friendId, friendName, friendGender, friendBirthday, hometown, currentLocation, friendLink, friendPicture, friendOnline) {
		var url = applicationRoot + friendId;
		return "<ul class='horizontal'>" +
				"<li><a href='" + url + "'><img src='" + friendPicture + "' alt='" + friendName + " Picture'/></a></li>" +
				"<li><a href='" + url + "'>" + friendName + "(" + friendGender + ")</a></li>" +
				"<li>" + (friendBirthday ? friendBirthday : "-----") + "</li>" +
				"<li>" + hometown + "</li>" +
				"<li>" + currentLocation + "</li>" +
				"</ul>";
}
window.fbAsyncInit = function() {
		FB.init({appId: applicationID, status: true, cookie: true,
				xfbml: true});
		FB.api(
		{
				method: "fql.query",
				query: "SELECT uid, name,sex, pic_small, birthday, hometown_location, current_location FROM user WHERE uid = " + currentUserId +
						" OR uid IN (SELECT uid2 FROM friend WHERE uid1 =" + currentUserId + ")"
		},
				function(response) {
						if (response.error_msg) {
								jQuery('#friendList').append(getHeaderHtml(response.error_msg));
								return;
						} else {
								friendList = response;
								showFriendsOnMapByHomeLocation();
						}
				})
};
function showFriendsOnMapByHomeLocation() {
		if (friendList) {
				regionWiseUsers = new Object();
				jQuery(friendList).each(function() {
						var regionString = getRegionString(this.hometown_location);
						addToState(this, regionString);
				});
				showFriendsOnMap(regionWiseUsers);
		}
}
function showFriendsOnMapByCurrentLocation() {
		if (friendList) {
				regionWiseUsers = new Object();
				jQuery(friendList).each(function() {
						var regionString = getRegionString(this.current_location);
						addToState(this, regionString);
				});
				showFriendsOnMap(regionWiseUsers);
		}
}
function showFriendsOnMap(regionWiseUsers) {
		clearMap();
		var divHtml = "";
		for (var index in regionWiseUsers) {
				divHtml += getRegionHeaderHtml(regionWiseUsers[index]);
				divHtml += "<div class='hidden'>";
				var popupHtml = "<div style='height:210px; width:200px'><h3>" + regionWiseUsers[index].name + "</h3><br/><ul>";
				jQuery(regionWiseUsers[index].users).each(function(key, userItem) {
						divHtml += getUserDetailListHtml(userItem);
						popupHtml += "<li style='list-style:none;'>" +
								"<a href='" + applicationRoot + "'" + userItem.uid + "'><img src='" + userItem.pic_small + "' alt='" + userItem.name + " Picture'/></a>" + userItem.name +
								"</li>";
				});
				popupHtml += "</div></ul>";
				searchAddress(regionWiseUsers[index].name, popupHtml);
				divHtml += "</div>";
		}
		jQuery('#friendList').empty().append(divHtml);
		applyAccordion();
}
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
		if (address.length && geocoder && address != noAddress) {
				var foundLocation = findAddressFromCache(address);
				if (foundLocation != null) {
						createMarkerAndInfoWindowForLocation(foundLocation, content, googleMap);
				} else {
						geocoder.geocode({ 'address': address}, function(results, status) {
								if (status == google.maps.GeocoderStatus.OK) {
										foundLocation = results[0].geometry.location;
										cachedAddress.push({address:address, position:foundLocation});
										createMarkerAndInfoWindowForLocation(foundLocation, content, googleMap);
								}
						});
				}
		}
		return false;
}

function createMarkerAndInfoWindowForLocation(location, content, map, icon) {
		if (!map) {
				map = googleMap;
		}
		var marker = new google.maps.Marker({map: map, position: location, draggable:true});
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
//			googleMap.setCenter(marker.getPosition());
		googleMap.fitBounds(googleMap.getBounds().extend(location));
		mapMarkerAndInfoWindows.push({marker:marker, infoWindow:infoWindow});
}
function applyAccordion() {
		$('#friendList .head').unbind('click');
		$('#friendList .head').click(function() {
				$(this).next().toggle('slow');
				return false;
		});
}
function updateHomeLocation(event, data) {
		googleMap.fitBounds(data.geometry.bounds);
}