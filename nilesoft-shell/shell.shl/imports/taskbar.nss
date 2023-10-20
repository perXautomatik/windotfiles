menu(type="taskbar" vis=key.shift() pos=0 title=app.name image=\uE249)
{
	item(pos=pos.middle title='Restart Explorer' sep=top image=icon.refresh type='Taskbar' cmd-line='/k taskkill /f /im explorer.exe & start explorer.exe & exit')
	item(pos=pos.middle title='Settings' sep=bottom image=icon.settings type='Taskbar' cmd='ms-settings:')

	item(pos=pos.bottom title='Enviroment Vars' image=icon.manage type='Taskbar' cmd='C:/Windows/system32/rundll32.exe' args='sysdm.cpl,EditEnvironmentVariables')
	item(pos=pos.bottom title='Task Manager' image=icon.task_manager type='Taskbar' cmd='Taskmgr.exe')
	item(title="config" image=\uE10A cmd='"@app.cfg"')
	item(title="manager" image=\uE0F3 admin cmd='"@app.exe"')
	item(title="directory" image=\uE0E8 cmd='"@app.dir"')
	item(title="version\t"+@app.ver vis=label col=1)
	item(title="docs" image=\uE1C4 cmd='https://nilesoft.org/docs')
	item(title="donate" image=\uE1A7 cmd='https://nilesoft.org/donate')
}
menu(where=@(this.count == 0 && isw11) type='taskbar' image=icon.settings expanded=true)
{
	menu(title="Apps" image=\uE254)
	{
		item(title='Paint' image=\uE116 cmd='mspaint')
		item(title='Edge' image cmd='@sys.prog32\Microsoft\Edge\Application\msedge.exe')
		item(title='Calculator' image=\ue1e7 cmd='calc.exe')
		item(title=@str.res('regedit.exe,-16') image cmd='regedit.exe')
	}
	menu(title=title.windows image=\uE1FB)
	{
		item(title=title.cascade_windows cmd=command.cascade_windows)
		item(title=title.Show_windows_stacked cmd=command.Show_windows_stacked)
		item(title=title.Show_windows_side_by_side cmd=command.Show_windows_side_by_side)
		sep
		item(title=title.minimize_all_windows cmd=command.minimize_all_windows)
		item(title=title.restore_all_windows cmd=command.restore_all_windows)
	}
	item(title=title.task_manager image=icon.task_manager cmd='taskmgr.exe')
	item(title=title.taskbar_Settings sep=both image=inherit cmd='ms-settings:taskbar')
	item(title=title.settings image=icon.settings(auto, @image.color1) cmd='ms-settings:')
	item(title=title.desktop image=icon.desktop cmd=command.toggle_desktop)
	item(vis=@key.shift() title=title.exit_explorer cmd=command.restart_explorer)
}