<html>
<head>
	<title>Login Failure</title>
	<style type="text/css">
	.message {
		border: 1px solid black;
		padding: 5px;
		background-color: #E9E9E9;
	}
	</style>
</head>

<body>
<h1>Facebook login failed</h1>
<h2>${error}</h2>

<div class="message">
	<strong>error_reason:</strong> ${error_reason}<br/>
	<strong>Description:</strong> ${error_description}<br/>
</div>
<div>
	<g:link controller="faceBook">Try again</g:link>
</div>
</body>
</html>