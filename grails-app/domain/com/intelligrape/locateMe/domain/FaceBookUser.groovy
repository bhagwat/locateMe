package com.intelligrape.locateMe.domain

import javax.jdo.annotations.*;
// import com.google.appengine.api.datastore.Key;

@PersistenceCapable(identityType = IdentityType.APPLICATION, detachable="true")
class FaceBookUser {

	@PrimaryKey
    @Persistent(valueStrategy = IdGeneratorStrategy.IDENTITY)
	Long id

	@Persistent
	String userId
	@Persistent
	String accessToken
	@Persistent
	String name
	@Persistent
	String picture
	@Persistent
	String email
	@Persistent
	boolean dirty=false

    static constraints = {
    	id( visible:false)
	}
}
