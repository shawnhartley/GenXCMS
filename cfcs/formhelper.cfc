<cfscript>
component {
	
	variables.fieldprefix = '';
	variables.monthList = ListToArray("January,February,March,April,May,June,July,August,September,October,November,December");
	variables.data = {};
	
	public void function setData(data) {
		variables.data = arguments.data;
		if(structKeyExists(url, 'debug')) this.data = arguments.data; // allow introspection for debug
	}
	public void function clearData() {
		this.data = {};
	}
	
	public string function getArg(required string item, boolean useForm = true) {
		if(arguments.useForm AND structKeyExists(form, trim(item))) { return trim(form[trim(item)]); }
		
		if( structkeyExists(variables.data, trim(item)) ) {
			if( isArray(variables.data[trim(item)]) ) { return trim(variables.data[trim(item)][1]); }
			return trim(variables.data[trim(item)]);
		}
		return '';
	}
	
	public string function textLabel(required string content,
									 required string name,
									 string classes = '') {
		var class = '';
		if( len(arguments.classes) ) {
			class=' class="#arguments.classes#"';
		}
		return '<label for="#variables.fieldprefix##arguments.name#"#class#>#arguments.content#</label>#text(arguments.name,arguments.classes)#';
	}

	public string function text(required string name, string classes = '') {
		var class = '';
		if( len(arguments.classes) ) {
			class=' class="#arguments.classes#"';
		}
		return '<input type="text" id="#variables.fieldprefix##arguments.name#" name="#variables.fieldprefix##arguments.name#" value="#HTMLEditFormat(getArg(arguments.name))#" #class# />';
	}
	
	public string function emailLabel(required string content,
									 required string name,
									 string classes = '') {
		var class = '';
		if( len(arguments.classes) ) {
			class=' class="#arguments.classes#"';
		}
		return '<label for="#variables.fieldprefix##arguments.name#"#class#>#arguments.content#</label>#email(arguments.name,arguments.classes)#';
	}
	
	public string function email(required string name, string classes = '') {
		var class = '';
		if( len(arguments.classes) ) {
			class=' class="#arguments.classes#"';
		}
		return '<input type="email" id="#variables.fieldprefix##arguments.name#" name="#variables.fieldprefix##arguments.name#" value="#HTMLEditFormat(getArg(arguments.name))#" #class# />';
	}
	
	public string function simpleSelect(required string name,
										required string optionlist,
												 string blankOption = '',
												 string classes = '') {
		var class='';
		var current = getArg(arguments.name);
		var myEntries = ListToArray(arguments.optionlist);
		var sb = createObject("java", "java.lang.StringBuilder").init();
		if( len(arguments.classes) ) { class='class="#arguments.classes#"'; }
		
		sb.append('<select name="#variables.fieldprefix##arguments.name#" id="#variables.fieldprefix##arguments.name#" #class#>');
		if (len(arguments.blankOption)) {
			sb.append('<option value="">#arguments.blankOption#</option>');
		}
		for(local.i = 1; i LTE ArrayLen(myEntries); local.i++) {
			sb.append('<option value="#HTMLEditFormat(trim(myEntries[local.i]))#"');
			if( current EQ trim(myEntries[local.i]) ) {
				sb.append(' selected="selected"');
			}
			sb.append('>#trim(myEntries[local.i])#</option>');
		}
		sb.append('</select>');
		return sb.toString();
	}
	
	public string function hourSelect(required string name) {
		return simpleSelect(arguments.name, '12 am, 1 am, 2 am, 3 am, 4 am, 5 am, 6 am, 7 am, 8 am, 9 am, 10 am, 11 am, 12 pm, 1 pm, 2 pm, 3 pm, 4 pm, 5 pm, 6 pm, 7 pm, 8 pm, 9 pm, 10 pm, 11 pm' , ' ');
	}
	
	public string function stateSelect(required string name, string classes = '', addCanada=false, abbreviate=true) {
		return writeStateSelect(variables.fieldprefix & arguments.name,arguments.abbreviate, arguments.addCanada, getArg(arguments.name), arguments.classes);
	}
	
	/**
	* Easily creates a state select dropdown/
	*
	* @param formVar      Name of form field to create. (Required)
	* @param abbreviate      If true, abbreviations are used. (Required)
	* @param addCanada      If true, adds Canadian provicnes. (Required)
	* @param selectedVal      Specifies which value to pre-select. (Optional)
	* @param cssclass      CSS class to use in generated form field. (Optional)
	* @return Returns a string.
	* @author Tony Felice (sites@breckcomm.com)
	* @version 0, January 6, 2009
	*/
	private string function writeStateSelect(formVar,abbreviate=true,addCanada=false){
		var abbrevList = "AL,AK,AZ,AR,CA,CO,CT,DE,DC,FL,GA,HI,ID,IL,IN,IA,KS,KY,LA,ME,MD,MA,MI,MN,MS,MO,MT,NE,NV,NH,NJ,NM,NY,NC,ND,OH,OK,OR,PA,RI,SC,SD,TN,TX,UT,VT,VA,WA,WV,WI,WY";
		var nameList = "Alabama,Alaska,Arizona,Arkansas,California,Colorado,Connecticut,Delaware,District of Columbia,Florida,Georgia,Hawaii,Idaho,Illinois,Indiana,Iowa,Kansas,Kentucky,Louisiana,Maine,Maryland,Massachusetts,Michigan,Minnesota,Mississippi,Missouri,Montana,Nebraska,Nevada,New Hampshire,New Jersey,New Mexico,New York,North Carolina,North Dakota,Ohio,Oklahoma,Oregon,Pennsylvania,Rhode Island,South Carolina,South Dakota,Tennessee,Texas,Utah,Vermont,Virginia,Washington,West Virginia,Wisconsin,Wyoming";
		var provCodeList = ",---,AB,BC,MB,NB,NL,NT,NS,NU,ON,PE,QC,SK,YT";
		var provList = ",-- CANADIAN PROVINCES --,Alberta,British Columbia,Manitoba,New Brunswick,Newfoundland and Labrador,Northwest Territories,Nova Scotia,Nunavut,Ontario,Prince Edward Island,Quebec,Saskatchewan,Yukon";
		var selectedVal = "";
		var cssclass="none";
		var stateSelect = "";
		if (ArrayLen(arguments) gt 3){
			selectedVal = arguments[4];
		}
		if(ArrayLen(arguments) gt 4){
			cssclass = arguments[5];
		}
		if(addCanada eq 1){
			abbrevList = abbrevList & provCodeList;
			nameList = nameList & provList;
		}
		stateSelect = "<select name=""" & formVar & """ class=""" & cssclass & """>";
		if(abbreviate){
			stateSelect = stateSelect & "<option value=""""></option>";
		}else{
			stateSelect = stateSelect & "<option value="""">Select State" & iif(addCanada eq 1,DE(" or Province"),DE("")) & "</option>";
		}
		for(i = 1;i lte listLen(abbrevList);i=i+1){
			stateSelect = stateSelect & "<option value=""" & listGetAt(abbrevList,i) & """ " & iif(selectedVal eq listGetAt(abbrevList,i),DE("selected"),DE("")) & ">" & iif(abbreviate eq 1,DE(listGetAt(abbrevList,i)),DE(listGetAt(nameList,i))) & "</option>";
		}
		stateSelect = stateSelect & "</select>";
		
		return stateSelect;
	}
	
	public string function stateSelectLabel(required string content, required string name, string classes = '',addCanada=false, abbreviate=true) {
		var class='';
		if( len(arguments.classes) ) {
			class = ' class="#arguments.classes#"';
		}
		return '<label#class#>#arguments.content#</label>#stateSelect(arguments.name,arguments.classes, arguments.addCanada, arguments.abbreviate)#';
	}
	
	public string function monthSelect(required string name,
									   			string classes = '',
												string blankOption = 'Please Select',
												string show = 'both') {
		var sb = createObject("java", "java.lang.StringBuilder").init();
		var class='';
		var select = '';
		var current = getArg(arguments.name);
		if( len(arguments.classes) ) {
			class = ' class="#arguments.classes#"';
		}
		sb.append('<select name="#arguments.name#" id="#arguments.name#"#class#>');
		if(len(arguments.blankOption)) {
			sb.append('<option value="">#blankOption#</option>');
		}
		for(local.i = 1; i LTE ArrayLen(variables.monthList); local.i++) {
			select = local.i EQ current ? ' selected="selected"' : '';
			sb.append('<option value="#NumberFormat(i,'00')#"#select#>');
			if( ListFind('both,number', arguments.show) ) {
				sb.append(NumberFormat(i,'00'));
			}
			if( arguments.show EQ 'both') { sb.append(' '); }
			if( ListFind('both,name', arguments.show)) {
				sb.append(variables.monthlist[local.i]);
			}
			sb.append('</option>');
		}
		sb.append('</select>');
		return sb.toString();
	}
	public string function yearSelect(required string name,
									  		   string classes = '',
											   numeric plus = 6,
											   numeric minus = 0,
											   string blankOption = '') {
		var myYear = YEAR(NOW());
		var i = 0;
		var years = ArrayNew(1);
		for(i=myYear - arguments.minus; i LTE myYear + arguments.plus; i++) {
			years[i] = i;
		}
		return simpleSelect(arguments.name, ArrayToList(years), arguments.blankOption, arguments.classes);
	}
	
	public string function numericDaySelect (required string name,
											 		  string classes = '',
													  string blankOption = '') {
		var sb = createObject("java", "java.lang.StringBuilder").init();
		var class='';
		var select = '';
		var current = getArg(arguments.name);
		if( len(arguments.classes) ) {
			class = ' class="#arguments.classes#"';
		}
		sb.append('<select name="#arguments.name#" id="#arguments.name#" #class#>');
		if( len(arguments.blankOption) ) {
			sb.append('<option value="">#arguments.blankOption#</option>');
		}
		for(local.i = 1; local.i LTE 31; local.i++) {
			sb.append('<option#local.i EQ current ? ' selected="selected"' : ''#>#local.i#</option>');
		}
		sb.append('</select>');
		return sb.toString();
	}
	
	public string function checkboxLabel(required string content,
										 required string name,
										 		  string value = arguments.content,
										 		  string classes = '') {
		var class='';
		var checked = '';
		if( len(arguments.classes) ) {
			class = ' class="#arguments.classes#"';
		}
		if( ListFind(getArg(arguments.name),arguments.value) ) {
			checked = ' checked="checked"';
		}
		return '<label#class#><input type="checkbox" name="#variables.fieldprefix##arguments.name#" value="#HTMLEditFormat(arguments.value)#"#checked##class# /> #arguments.content#</label>';
	}
	
	public string function radioLabel (	required string content,
										required string name,
										required string value,
												 string classes = '') {
		var class='';
		var checked = '';
		if( len(arguments.classes) ) {
			class = ' class="#arguments.classes#"';
		}
		if( ListFind(getArg(arguments.name),arguments.value) ) {
			checked = ' checked="checked"';
		}
		return '<label#class#><input type="radio" name="#variables.fieldprefix##arguments.name#" value="#HTMLEditFormat(arguments.value)#"#checked##class# /> #arguments.content#</label>';
	}
	
	public string function yesNo(required string name, string initial='', string classes = '') {
		var sb = createObject("java", "java.lang.StringBuilder").init();
		var class='';
		var current=getArg(arguments.name);
		if( len(arguments.classes) ) {
			class = ' class="#arguments.classes#"';
		}
		if( isBoolean(arguments.initial) AND NOT isBoolean(current) ) {
			current = arguments.initial;
		}
		sb.append('<select name="#variables.fieldprefix##arguments.name#" size="2" class="yesNo #arguments.classes#" id="#arguments.name#">');
		sb.append('<option value="No"#isBoolean(current) AND NOT current ? ' selected="selected"' : ''#>No</option>');
		sb.append('<option value="Yes"#isBoolean(current) AND current ? ' selected="selected"' : ''#>Yes</option>');
		sb.append('</select>');
		return sb.toString();
	}
	
	public string function yesNoLabel(required string content, required string name, string initial='', string classes = '') {
		var class='';
		if( len(arguments.classes) ) {
			class = ' class="#arguments.classes#"';
		}
		return '<label#class# for="#variables.fieldprefix##arguments.name#">#arguments.content#</label> #yesNo(arguments.name,arguments.initial,arguments.classes)#';
	}
	
	public string function areaLabel(required string content, required string name, string classes = '') {
		var class='';
		if( len(arguments.classes) ) {
			class = ' class="#arguments.classes#"';
		}
		return '<label#class# for="#variables.fieldprefix##arguments.name#">#arguments.content#</label> #area(arguments.name,arguments.classes)#';
	}
	
	public string function area(required string name, string classes = '') {
		var class='';
		if( len(arguments.classes) ) {
			class = ' class="#arguments.classes#"';
		}
		return '<textarea name="#variables.fieldprefix##arguments.name#" id="#variables.fieldprefix##arguments.name#" rows="3" cols="25"#class#>#HTMLEditFormat(getArg(arguments.name))#</textarea>';
	}
	public string function hidden(required string name) {
		return '<input type="hidden" name="#variables.fieldprefix##arguments.name#" value="#HTMLEditFormat(getArg(arguments.name))#" />';
	}
	
	public string function processUpload( required string field, string uploadpath = '/uploads/' ) {
		var result = '';
		var fullpath = ExpandPath(arguments.uploadpath);
		if (NOT directoryExists(fullpath)) {
			DirectoryCreate(fullpath);
		}
		result = fileUpload(ExpandPath('/uploads/'),arguments.field, "*", "makeUnique");
		return '/uploads/' & result.serverFile;
	}
}
</cfscript>