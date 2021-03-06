var googleMap;
var applicationID;
var currentUserId;
var applicationRoot;
var applicationServerUrl;
var regionWiseUsers;
var friendList;
var mapMarkerAndInfoWindows = new Array();
var cachedAddressSearches = new Array();
var googleLineObjects = new Array();
var NO_ADDRESS = "No Address";
var NOT_SEARCHED = "Not Searched";
var SUCCESS = "Success";
var FAILED = "Failed";
var MAX_ALLOWED_SEARCH_ATTEMPT = 4;
function printLog(objectToLog) {
    /*
     if (console && console.log != undefined) {
     console.log(objectToLog);
     }
     */
}
function getLocationType() {
    var locationType = jQuery('input[name=searchBy]:checked').val();
    return locationType.length ? locationType : 'hometown_location';
}
function findAddressFromCache(address) {
    for (var k in cachedAddressSearches) {
        if (cachedAddressSearches[k].address == address) {
            return cachedAddressSearches[k].position;
        }
    }
    return null;
}
function numberOfValidRegions() {
    var totalRegions = 0;
    for (var region in regionWiseUsers) {
        if (!(region == NO_ADDRESS || regionWiseUsers[region].searchStatus == FAILED)) {
            totalRegions++;
        }
    }
    return totalRegions;
}
function numberOfFailedSearches() {
    var totalRegions = 0;
    for (var region in regionWiseUsers) {
        if (regionWiseUsers[region].searchStatus == FAILED) {
            totalRegions++;
        }
    }
    return totalRegions;
}
function setAddressSearchStatus(address, newStatus) {
    for (var region in regionWiseUsers) {
        if (region == address)
            regionWiseUsers[region].searchStatus = newStatus;
    }
}
function clearMap() {
    removeAllLines();
    jQuery(mapMarkerAndInfoWindows).each(function() {
        if (this.marker) this.marker.setMap(null);
        if (this.infoWindow) this.infoWindow = null;
    });
    mapMarkerAndInfoWindows = new Array();
}
function getRegionString(addressToSearch) {
    var addressToReturn = NO_ADDRESS;
    if (addressToSearch) {
        if (addressToSearch.city) {
            addressToReturn = addressToSearch.city;
        }
        if (addressToSearch.state) {
            addressToReturn += (" " + addressToSearch.state);
        }
        if (addressToSearch.country) {
            addressToReturn += (" " + addressToSearch.country);
        }
    }
    return addressToReturn;
}
function addToState(index, userItem, regionString) {
    if (!regionWiseUsers[regionString]) {
        regionWiseUsers[regionString] = new Object();
        regionWiseUsers[regionString].index = index;
        regionWiseUsers[regionString].searchStatus = NOT_SEARCHED;
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
    return friendTdFbApi(friendId, friendName, friendGender, friendBirthday, hometown, currentLocation, friendLink, friendPicture, friendOnline);
}
function getHeaderHtml(text) {
    return "<h3 class='head'><a href='#'>" + text + "</a></h3>";
}
function getRegionHeaderHtml(regionItem) {
    return getHeaderHtml(regionItem.name + " : " + regionItem.users.length + " Friends");
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
function showFriendsOnMapBySelectedLocation() {
    if (friendList) {
        regionWiseUsers = new Object();
        var index = 0;
        jQuery(friendList).each(function() {
            var regionString = getRegionString(this[getLocationType()]);
            addToState(index++, this, regionString);
        });
        showFriendsOnMap(regionWiseUsers);
    }
}
function showFriendsOnMap(regionWiseUsers) {
    clearMap();
    var delay = 0;
    var divHtml = "";
    for (var counter in regionWiseUsers) {
        var address = regionWiseUsers[counter].name;
        divHtml += getRegionHeaderHtml(regionWiseUsers[counter]);
        divHtml += "<div class='hidden'>";
        var popupHtml = "<div style='height:210px; width:200px'><h3>" + address + "</h3><br/><ul>";
        jQuery(regionWiseUsers[counter].users).each(function(key, userItem) {
            divHtml += getUserDetailListHtml(userItem);
            popupHtml += "<li style='list-style:none;'>" +
                    "<a href='" + applicationRoot + "'" + userItem.uid + "'><img src='" + userItem.pic_small + "' alt='" + userItem.name + " Picture'/></a>" + userItem.name +
                    "</li>";
        });
        popupHtml += "</div></ul>";
        divHtml += "</div>";
        var foundLocation = findAddressFromCache(address);
        if (foundLocation != null) {
            printLog("location found in cache for address :" + address);
            createMarkerAndInfoWindowForLocation(foundLocation, popupHtml, googleMap, regionWiseUsers[counter].users[0].pic_small);
            setAddressSearchStatus(address, SUCCESS);
        } else {
            searchAddress(address, popupHtml, regionWiseUsers[counter].users[0].pic_small);
        }
    }
    jQuery('#friendList').html(divHtml);
    applyAccordion();
}

function searchAddress(address, content, imageUrl) {
    var geocoder = getGeoCoder();
    if (address.length && geocoder && address != NO_ADDRESS) {
        geocoder.geocode({ 'address': address}, function(results, status) {
            if (status == google.maps.GeocoderStatus.OK) {
                foundLocation = results[0].geometry.location;
                cachedAddressSearches.push({address:address, position:foundLocation});
                printLog("address found for : " + address + ", Status : " + status);
                createMarkerAndInfoWindowForLocation(foundLocation, content, googleMap, imageUrl);
                setAddressSearchStatus(address, SUCCESS);
            } else {
                printLog("address not found for : " + address + ", Status : " + status);
                setAddressSearchStatus(address, FAILED);
            }
        });
    } else {
        setAddressSearchStatus(address, FAILED);
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
    mapMarkerAndInfoWindows.push({marker:marker, infoWindow:infoWindow});
    checkAndFitBoundary();
}

function checkAndFitBoundary() {
    if (mapMarkerAndInfoWindows.length >= numberOfValidRegions() - 2) {
        printLog("All Locations have been searched. Failed searches : " + numberOfFailedSearches());
        var bounds = new google.maps.LatLngBounds();
        for (marker in mapMarkerAndInfoWindows) {
            bounds.extend(mapMarkerAndInfoWindows[marker].marker.getPosition());
        }
        if (!bounds.isEmpty()) {
            googleMap.fitBounds(bounds);
        }
    }
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
function removeAllLines() {
    for (var arrow in googleLineObjects) {
        googleLineObjects[arrow].setMap(null);
    }
    googleLineObjects = new Array();
}
function showGoogleMapLineConnections() {
    removeAllLines();
    for (var friend in friendList) {
        if (friendList[friend].uid == currentUserId) {
            var foundLocation = findAddressFromCache(getRegionString(friendList[friend][getLocationType()]));
            for (region in regionWiseUsers) {
                if (region != NO_ADDRESS && regionWiseUsers[region].seachAddress != FAILED) {
                    checkAndShowGoogleMapLine(foundLocation, region);
                }
            }
            return;
        }
    }
}
function checkAndShowGoogleMapLine(startPosition, endRegion) {
    var endPosition = null;
    for (var k in cachedAddressSearches) {
        if (cachedAddressSearches[k].address == endRegion) {
            endPosition = cachedAddressSearches[k].position;
        }
    }
    if (startPosition) {
        if (endPosition && endPosition != startPosition) {
            var linePath = new google.maps.Polyline({
                path: [startPosition, endPosition],
                strokeColor: "#FF0000",
                strokeOpacity: 1.0,
                strokeWeight: 2
            });
            linePath.setMap(googleMap);
            googleLineObjects.push(linePath);
        }
    } else {
        jQuery.flash.warn('Address not set', 'We are unable to find your ' + getLocationType() + ". Possibly you do not have updated this in your facebook profile. Update your location to see connection.")
    }
}
function loadFaceBookFriendDetails() {
    FB.api(
    {
        method: "fql.query",
        query: "SELECT uid, name,sex, pic_small, birthday, hometown_location, current_location FROM user WHERE uid = " + currentUserId +
                " OR uid IN (SELECT uid2 FROM friend WHERE uid1 =" + currentUserId + ")"
    }, function(response) {
                if (response.error_msg) {
                    jQuery.flash.subtle('Hmm...', "We are unable to load your friend list due to: " + response.error_msg + ". Click Reload");
                    var message = "<h3>" + getHeaderHtml(response.error_msg) + "<a href='" + applicationRoot + "'>Reload</a></h3>";
                    jQuery('#friendList').html(message);
                } else {
                    friendList = response;
                    showFriendsOnMapBySelectedLocation();
                }
            }
            );
}
function postOnWall() {
    var divHtml = "";
    for (var counter in regionWiseUsers) {
        if (counter > 5) break;
        divHtml += regionWiseUsers[counter].name + ": " + regionWiseUsers[counter].users.length + ",\n"
    }
    FB.ui(
    {
        method: 'feed',
        name: 'Region wise Friends based on ' + getLocationType(),
        link: applicationRoot,
        picture:applicationServerUrl + "/images/find-me-on-google-map-logo.jpg",
        description: divHtml
    },
            function(response) {
                if (response && response.post_id) {
                    jQuery.flash.success('Success', 'Your region wise friend statistics has been successfully posted on your wall.')
                } else {
                    jQuery.flash.error('Error', 'Your region wise friend statistics was not posted on your wall.')
                }
            }
            )
}
jQuery(document).ready(function() {
    jQuery('input[name=searchBy]').click(function() {
        showFriendsOnMapBySelectedLocation();
    });
    loadFaceBookFriendDetails();
});