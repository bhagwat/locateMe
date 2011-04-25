package com.intelligrape.locateMe.controller

import grails.converters.JSON

class FaceBookController {
	static final String APPLICATION_ID = '186418821373054'
	static final String FACEBOOK_PERMISSIONS = "offline_access,publish_stream,user_about_me,user_birthday,friends_birthday,user_education_history,friends_education_history,user_hometown,friends_hometown,user_location,friends_location,user_work_history,friends_work_history,user_website,friends_website"
	static final String SECRET_KEY = "ecde4773f33cc1d662c1bb3ccfd3a9d2"
	static final String GRAPH_BASIC_URL = "https://graph.facebook.com/"
	static final Integer PAGE_SIZE = 25

	def index = {
		log.info params
		String redirectURI = createLink(absolute: true, action: 'handleUser')
		String facebookAuthorizeUrl = "https://www.facebook.com/dialog/oauth?client_id=${APPLICATION_ID}&redirect_uri=${redirectURI}&scope=${FACEBOOK_PERMISSIONS}"
		redirect(url: facebookAuthorizeUrl)
	}
	def handleUser = {
		log.info params
		String authCode = params.code
		if (authCode) {
			List facebookUrlParts = [
					"${GRAPH_BASIC_URL}oauth/access_token?client_id=${APPLICATION_ID}",
					"client_secret=" + SECRET_KEY.encodeAsURL(),
					"code=" + authCode.encodeAsURL(),
					"redirect_uri=${createLink(absolute: true, action: 'handleUser')}",
					"scope=${FACEBOOK_PERMISSIONS}"
			]
			URL url = new URL(facebookUrlParts.join("&"))
			String response = url.text
			if (response.contains('access_token=')) {
				String[] resp = response.split('access_token=')
				String accessToken = resp[1]
				log.info "Facebook Access Token: ${accessToken}"
				session['fb_token'] = accessToken
				redirect(action: "userInfo")
			}
		} else {
			redirect(action: 'index')
		}
	}

	def userInfo = {
		log.info params
		if (faceBookToken) {
			try {
				String uid = params.id ?: getUserId()
				String urlUserDetail = "${GRAPH_BASIC_URL}${uid}?access_token=${faceBookToken.encodeAsURL()}"
				String urlUserDetailResponseText = urlUserDetail.toURL().getText('ISO-8859-1')
				def userDetail = JSON.parse(urlUserDetailResponseText)
				println userDetail
				String fields = "id,name,link,gender,picture"
				String urlFriendsList = "${GRAPH_BASIC_URL}${uid}/friends?access_token=${getFaceBookToken().encodeAsURL()}&fields=${fields}&limit=10"
				String friendListResponseText = urlFriendsList.toURL().getText('ISO-8859-1')
				def friendList = JSON.parse(friendListResponseText)
				[userInfo: userDetail, friendList: friendList, loggedInUserId:userId, applicationID:APPLICATION_ID, permissions:FACEBOOK_PERMISSIONS]
			} catch (exception) {
				render view:'/error'
			}

		} else {
			redirect(controller: 'faceBook', action: 'index')
		}
	}

	private String getUserId() {
		String token = getFaceBookToken().tokenize("|")[1]
		String uid = token.tokenize("-")[1]
		log.info "userId : " + uid
		return uid
	}

	private String getFaceBookToken() {
		return session.fb_token
	}

	def test = {
		log.info params
	}
	def register = {
		log.info params
		render params
	}
}
