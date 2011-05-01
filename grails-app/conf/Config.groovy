grails.project.groupId = appName // change this to alter the default package name and Maven publishing destination
grails.mime.file.extensions = true // enables the parsing of file extensions from URLs into the request format
grails.mime.use.accept.header = false
grails.mime.types = [html: ['text/html', 'application/xhtml+xml'],
		xml: ['text/xml', 'application/xml'],
		text: 'text/plain',
		js: 'text/javascript',
		rss: 'application/rss+xml',
		atom: 'application/atom+xml',
		css: 'text/css',
		csv: 'text/csv',
		all: '*/*',
		json: ['application/json', 'text/json'],
		form: 'application/x-www-form-urlencoded',
		multipartForm: 'multipart/form-data'
]

// URL Mapping Cache Max Size, defaults to 5000
//grails.urlmapping.cache.maxsize = 1000

// The default codec used to encode data with ${}
grails.views.default.codec = "none" // none, html, base64
grails.views.gsp.encoding = "UTF-8"
grails.converters.encoding = "UTF-8"
// enable Sitemesh preprocessing of GSP pages
grails.views.gsp.sitemesh.preprocess = true
// scaffolding templates configuration
grails.scaffolding.templates.domainSuffix = 'Instance'

// Set to false to use the new Grails 1.2 JSONBuilder in the render method
grails.json.legacy.builder = false
// enabled native2ascii conversion of i18n properties files
grails.enable.native2ascii = true
// whether to install the java.util.logging bridge for sl4j. Disable for AppEngine!
grails.logging.jul.usebridge = true
// packages to include in Spring bean scanning
grails.spring.bean.packages = []

// set per-environment serverURL stem for creating absolute links
environments {
	production {
		grails.serverURL = "http://bhagwat-kumar.appspot.com"
	}
	development {
		grails.serverURL = "http://bhagwat-kumar.appspot.com"
	}
	test {
		grails.serverURL = "http://bhagwat-kumar.appspot.com"
	}
}
facebook {
	applicationId = "186418821373054"
	permissions = "offline_access,publish_stream,user_about_me,user_birthday,friends_birthday,user_education_history,friends_education_history,user_hometown,friends_hometown,user_location,friends_location,user_work_history,friends_work_history,user_website,friends_website"
	secretKey = "ecde4773f33cc1d662c1bb3ccfd3a9d2"
	graphApiBasicUrl = "https://graph.facebook.com/"
	oauthUrl="https://www.facebook.com/dialog/oauth"
}

// log4j configuration
log4j = {
	// Example of changing the log pattern for the default console
	// appender:
	//
	appenders {
	    console name:'stdout', layout:pattern(conversionPattern: '%c{2} %m%n')
	}

	error 'org.codehaus.groovy.grails.web.servlet',	//  controllers
			'org.codehaus.groovy.grails.web.pages', //  GSP
			'org.codehaus.groovy.grails.web.sitemesh', //  layouts
			'org.codehaus.groovy.grails.web.mapping.filter', // URL mapping
			'org.codehaus.groovy.grails.web.mapping', // URL mapping
			'org.codehaus.groovy.grails.commons', // core / classloading
			'org.codehaus.groovy.grails.plugins', // plugins
			'org.codehaus.groovy.grails.orm.hibernate', // hibernate integration
			'org.springframework',
			'org.hibernate',
			'net.sf.ehcache.hibernate'

	warn 'org.mortbay.log'
	error 'com.intelligrape.locateMe.controller'
}
