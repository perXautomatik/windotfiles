shell
{
	var
	{
		isw11=sys.is11
	}
	
	set
	{
		theme
		{
			name="modern"
			background
			{
				//opacity=85
				//effect=1
			}
			image.align = 2// 0 = checked, 1 = image, 2 = both
		}

		tip
		{
			enabled=1
			opacity=100
			width=400
			radius=1
			time=1.25
			padding=[10,10]
		}

		exclude.where = !process.is_explorer
		showdelay=200
	}

	images import 'imports/images.nss'

	static
	{	
		import 'imports/static.nss'
		item(where=this.title.length > 25 menu=title.more_options)
	}

	dynamic
	{
		menu(mode="multiple" title="Pin/Unpin" image=icon.pin) { }
		menu(mode="multiple" title=title.more_options image=icon.more_options) { }
		
		separator
		item(where=sys.ver.major >= 10 title=title.Windows_Terminal tip=tip_run_admin admin=key.shift() image='@package.path("WindowsTerminal")\WindowsTerminal.exe' cmd='wt.exe' arg='-d "@sel.path\."')
		item(title='Visual Studio Code' image=[\uE272, #22A7F2] cmd='code' args='"@sel.path"')
		separator
		import 'imports/terminal.nss'
		import 'imports/file-manage.nss'
		import 'imports/develop.nss'
		import 'imports/goto.nss'
		import 'imports/taskbar.nss'
	}
}