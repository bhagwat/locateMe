<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
    <meta name="layout" content="main"/>
    <title><g:message code="where.are.your.friends" default="Where are your friends?"/></title>
    <script type="text/javascript" src="http://maps.google.com/maps/api/js?sensor=false"></script>
    <script type="text/javascript">
        var applicationID = "${grailsApplication.config.facebook.applicationId}";
        var currentUserId = "${currentUserId}";
        var applicationRoot = "${grailsApplication.config.grails.serverURL}/faceBook/userInfo/";
        var applicationServerUrl = "${grailsApplication.config.grails.serverURL}";
    </script>
    <g:javascript src="findme.facebook-9.js"/>
    <g:javascript src="jquery.flash.js"/>
</head>
<body style="margin:5px;">
<div id="fb-root"></div>
<script type="text/javascript" src="http://connect.facebook.net/en_US/all.js"></script>
<script type="text/javascript">
    FB.init({
        appId: applicationID,
        status: true,
        cookie: true,
        xfbml: true,
        channelUrl  : "${grailsApplication.config.grails.serverURL}/channel.html"  // custom channel
    });
    FB.Canvas.setAutoResize();
</script>
<div id="flash"></div>
<div id="login-flow">
    <fb:login-button perms="${grailsApplication.config.facebook.permissions}" show-faces="true"></fb:login-button>
</div>
<table>
    <tr>
        <td>
            <h2>
                Welcome
                <a href="${createLink(action: 'userInfo', id: loggedInUserId)}">
                    ${userInfo.name}
                </a>
            </h2>
        </td>
        <td>
            <div class="navigation">
                Search By
                <g:radio value="hometown_location" name="searchBy" checked="true"/>Home town
                <g:radio value="current_location" name="searchBy"/>Current town
                <input type="button" onclick="$('#friendList .head').next().hide();" value="${message(code: 'collapse.all')}"/>
                <input type="button" onclick="$('#friendList .head').next().show();" value="${message(code: 'expand.all')}"/>
                <input type="button" onclick="showGoogleMapLineConnections();" value="Connect line"/>
                <input type="button" onclick="postOnWall();" value="Post on wall"/>
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
