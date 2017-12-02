class profiles {
  load( nProfile ) { ; 1 - profile cannot be loaded
    nData := json.read( "profiles\" nProfile ".json" )
    if ( !isObject( nData ) )
      return 1
    global data := nData
  }
  change() {

  }
  save() {

  }
  _refreshList() {
    loop 32 {
      msgbox %  "Edit" ( a_index - 1 ) * 2 + 1 " <==> " getKeyName(data[a_index]["hotkey"])
      GuiControl, mainWin:,% "Edit" ( a_index - 1 ) * 2 + 1, getKeyName(data[a_index]["hotkey"])
      GuiControl, mainWin:,% "Edit"  a_index * 2, data[a_index]["name"])
    }
  }
}
