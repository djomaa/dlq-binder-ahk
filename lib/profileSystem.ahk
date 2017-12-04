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
  refreshList() {
    loop 32 {
      GuiControl, mainWin:,% "Edit" ( a_index - 1 ) * 2 + 1,% hkc.getName(data[a_index]["hotkey"])
      GuiControl, mainWin:,% "Edit"  a_index * 2,% data[a_index]["name"]
    }
  }
}
