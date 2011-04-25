class ApplicationFilters {

	def filters = {
		all(controller: '*', action: '*') {
			before = {
				log.info "[Application Access Log : ${new Date()}]: $params"

			}
			after = {

			}
			afterView = {

			}
		}
	}

}
