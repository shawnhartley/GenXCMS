/**
 * @license Copyright (c) 2003-2015, CKSource - Frederico Knabben. All rights reserved.
 * For licensing, see LICENSE.md or http://ckeditor.com/license
 */

CKEDITOR.editorConfig = function( config ) {
	// Define changes to default configuration here.
	// For complete reference see:
	// http://docs.ckeditor.com/#!/api/CKEDITOR.config

	config.extraPlugins = 'indentblock';
	config.extraPlugins = 'justify';
	config.uiColor = '#41b6e6;';
    config.contentsCss = ['/css/editor.css'];
	config.bodyId = 'copy';	
	config.pasteFromWordPromptCleanup = true;

	config.filebrowserBrowseUrl = '/managementcenter/ckeditor/plugins/filemanager/index.cfm';
	config.filebrowserImageBrowseUrl = '/managementcenter/ckeditor/plugins/filemanager/index.cfm';
	config.filebrowserFlashUploadUrl = '/managementcenter/ckeditor/plugins/filemanager/index.cfm';
	config.filebrowserFlashBrowseUrl = '/managementcenter/ckeditor/plugins/filemanager/index.cfm';	

	// The toolbar groups arrangement, optimized for two toolbar rows.
	config.toolbarGroups = [
		{ name: 'clipboard',   groups: [ 'clipboard', 'undo' ] },
		{ name: 'editing',     groups: [ 'find', 'selection', 'spellchecker' ] },
		{ name: 'links' },
		{ name: 'insert' },
		{ name: 'forms' },
		{ name: 'tools' },
		{ name: 'document',	   groups: [ 'mode', 'document', 'doctools' ] },
		{ name: 'others' },
		'/',
		{ name: 'basicstyles', groups: [ 'basicstyles', 'cleanup' ] },
		{ name: 'paragraph',   groups: [ 'list', 'indent', 'blocks', 'align', 'bidi' ] },
		{ name: 'styles' },
		{ name: 'colors' },
		{ name: 'about' },
		{ name: 'justify' }
	];

	// Remove some buttons provided by the standard plugins, which are
	// not needed in the Standard(s) toolbar.
	config.removeButtons = 'Underline,Subscript,Superscript';

	// Which elements should show in ckeditor tags? Set the most common block elements. 
	config.format_tags = 'p;h1;h2;h3;h4;h5;h6;address;pre';

	// Simplify the dialog windows.
	//config.removeDialogTabs = 'image:advanced;link:advanced';
};
