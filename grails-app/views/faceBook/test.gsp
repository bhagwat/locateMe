<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
	<meta name="layout" content="main"/>
	<title>JavaScript SDK test</title>
	<script type="text/javascript">
		jQuery(document).ready(function() {
			$('.accordion .head').click(
				function() {
					$(this).next().toggle('slow');
					return false;
				}).next().hide();
		});
	</script>
</head>
<body>

<div id="accordion">
	<h3><a href="#">First header</a></h3>
	<div>
		First content<br/>
		First content<br/>
		First content<br/>
		First content<br/>
		First content<br/>
		First content<br/>
	</div>
	<h3><a href="#">Second header</a></h3>
	<div>
		Second content <br/>
		Second content <br/>
		Second content <br/>
		Second content <br/>
		Second content <br/>
	</div>
</div>
</div>
</body>
</html>