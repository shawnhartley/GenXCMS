<cfscript>
component output="no" extends="Event" {
	public rssreader function init(required string source){
		var id = hash(arguments.source);
		this.data = cacheGet("news_#id#");
		if(structKeyExists(url,'cachebuster')) structDelete(this,'data');
		try {
			if(isNull(this.data)) {
				var fr = new feed().read(source=arguments.source);
				this.data = fr.query;
				cachePut("news_#id#",this.data, createTimeSpan(0,2,0,0));
			}
		} catch (Any e) {
			rethrow;
		}
		return this;
	}
}

</cfscript>