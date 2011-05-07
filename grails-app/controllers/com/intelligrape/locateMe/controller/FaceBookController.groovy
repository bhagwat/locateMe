package com.intelligrape.locateMe.controller

import grails.converters.JSON

class FaceBookController {
	def grailsApplication

	def index = {
		redirect(url: facebookAuthorizeUrl)
	}

	def accessDenied = {
	}

	def requestAuthorizationCode = {
		if (params.error) {
			log.info "Possibly user denied the application or login failed"
			redirect(action: 'accessDenied', params: params)
			return
		}
		if (!params.code) {
			log.info "User directly came to this url"
			redirect action: index
			return
		}
		String accessTokenResponse = getAuthenticateApplicationUrl(params.code).toURL().getText('ISO-8859-1')
		if (accessTokenResponse.contains('access_token=')) {
			String[] resp = accessTokenResponse.split('access_token=')
			String accessToken = resp[1]
			session['fb_token'] = accessToken
			redirect(action: "userInfo")
		} else {
			redirect(action: 'index')
		}
	}

	def userInfo = {
		if (!getFaceBookToken()) {
			redirect(action: 'index')
		}
		String currentUserId = params.id ?: getUserId()
		println "User Id to display detail : " + currentUserId
		String urlUserDetailResponseText = getUserDetailUrl(currentUserId).toURL().getText('ISO-8859-1')
		def userDetail = JSON.parse(urlUserDetailResponseText)
		[
				userInfo: userDetail,
				loggedInUserId: userId,
				currentUserId: currentUserId,
		]
	}
	def test={
		[loggedInUserId:getUserId()]
	}

	private String getFacebookAuthorizeUrl() {
		return grailsApplication.config.facebook.oauthUrl + "?" +
				[
						"client_id": grailsApplication.config.facebook.applicationId,
						"redirect_uri": createLink(absolute: true, action: 'requestAuthorizationCode'),
						"scope": grailsApplication.config.facebook.permissions
				].collect {attribute, value -> "${attribute}=${value.encodeAsURL()}"}.join("&")
	}

	private String getAuthenticateApplicationUrl(String facebookAuthCode) {
		return grailsApplication.config.facebook.graphApiBasicUrl + "oauth/access_token?" +
				[
						"client_id": grailsApplication.config.facebook.applicationId,
						"client_secret": grailsApplication.config.facebook.secretKey,
						"code": facebookAuthCode,
						"redirect_uri": createLink(absolute: true, action: 'requestAuthorizationCode'),
						"scope": grailsApplication.config.facebook.permissions
				].collect {attribute, value -> "${attribute}=${value.encodeAsURL()}"}.join("&")
	}

	private String getUserDetailUrl(String currentUserId) {
		return grailsApplication.config.facebook.graphApiBasicUrl + currentUserId + "?access_token=${faceBookToken.encodeAsURL()}"
	}

	private String getUserId() {
		String token = getFaceBookToken().tokenize("|")[1]
		String uid = token?.tokenize("-")[1]
		return uid
	}

	private String getFaceBookToken() {
		return session['fb_token']
	}
}
