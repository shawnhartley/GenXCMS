/**
 * @license Copyright (c) 2003-2015, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.md or http://ckeditor.com/license
 */

CKEDITOR.editorConfig = function( config ) {
	// Define changes to default configuration here.
	// For complete reference see:
	// http://docs.ckeditor.com/#!/api/CKEDITOR.config

	config.extraPlugins = 'youtube,filebrowser';
	config.extraAllowedContent = "*(youtube)";
	config.uiColor = '#cccccc;';
    config.contentsCss = ['/css/editor.css'];
	config.bodyId = 'copy';	
	config.pasteFromWordPromptCleanup = true;

	config.filebrowserBrowseUrl = '/managementcenter/ckeditor/plugins/filemanager/index.cfm';
	config.filebrowserImageBrowseUrl = '/managementcenter/ckeditor/plugins/filemanager/index.cfm';
	config.filebrowserFlashUploadUrl = '/managementcenter/ckeditor/plugins/filemanager/index.cfm';
	config.filebrowserFlashBrowseUrl = '/managementcenter/ckeditor/plugins/filemanager/index.cfm';	

	// The toolbar groups arrangement, optimized for two toolbar rows.
	config.toolbarGroups = [
		{ name: 'document', groups: [ 'mode', 'document', 'doctools' ] },
		{ name: 'clipboard', groups: [ 'clipboard', 'undo' ] },
		{ name: 'editing', groups: [ 'find', 'selection', 'spellchecker', 'editing' ] },
		{ name: 'forms', groups: [ 'forms' ] },
		'/',
		{ name: 'tools', groups: [ 'tools' ] },
		{ name: 'insert', groups: [ 'insert' ] },
		{ name: 'links', groups: [ 'links' ] },
		{ name: 'about', groups: [ 'about' ] },
		{ name: 'paragraph', groups: [ 'list', 'indent', 'blocks', 'align', 'bidi', 'paragraph' ] },
		'/',
		{ name: 'basicstyles', groups: [ 'basicstyles', 'cleanup' ] },
		{ name: 'styles', groups: [ 'styles' ] },
		{ name: 'colors', groups: [ 'colors' ] },
		{ name: 'others', groups: [ 'others' ] }
	];

	config.removeButtons = 'Save,NewPage,Preview,Print,Templates,Subscript,Superscript,CopyFormatting,BidiLtr,BidiRtl,Language,Flash,Table,TextColor,BGColor,ShowBlocks,Form,Checkbox,Radio,TextField,Textarea,Select,Button,ImageButton,HiddenField,SelectAll';

	// Which elements should show in ckeditor tags? Set the most common block elements. 
	config.format_tags = 'p;h1;h2;h3;h4;h5;h6;address;pre';

	// Simplify the dialog windows.
	//config.removeDialogTabs = 'image:advanced;link:advanced';
};
