class editing {
    __Call(method, args*) {
    if (method = "")  ; For %fn%() or fn.()
        return this.Call(args*)
    if (IsObject(method))  ; If this function object is being used as a method.
        return this.Call(method, args*)
}
  start( index ) {
      editing%index% := new editing( index )
  }
  __new( index ) {
    this.index := index
    this.name := data[index]["name"]
    this.hotkey := data[index]["hotkey"]
    this.text := data[index][text]

    gui, editing: New, +OwnermainWin -SysMenu +LabelChanging_
		gui, font,, Verdana
		gui, color, white, white
		gui, add, button, x-100 y-100 Default, Enter ;TODO !!!!!!!!!!!!!!!!!
		gui, add, groupBox, x5 y5 w200 h41 Section, Название
		gui, add, edit, xp+5 yp+15 w190 limit25 gediting.editString,% data[Change.Index]["Name"]

		gui, add, groupBox, xs+203 ys w100 h41 Section , Активация:
		gui, add, edit, xs+5 ys+15 w90 r1 +HWNDhotkey +backGroundTrans +readOnly
		gui, add, groupBox, xs+103 ys h41 w174 Section
		gui, add, button, xs+4 ys+10 w166 +hwndvar gthis.editString, Помощь
    ;fuck := objBindMethod(this,"editString" )
    ;guiControl, +g,% var, this.editString
		gui, add, groupBox, x5 y42 w480 h305 Section
		gui, add, listView, xs+7 ys+13 r14.5 w466 +HWNDtext -LV0x10 +ReadOnly +noSortHdr +Grid +Count99 -Multi , #|M|Text|L|Delay|

    gui, Font, underline
		gui, add, text, xs+150 ys+283 +backGroundTrans gediting.addString, Добавить
		gui, Font, norm bold
		gui, add, text, x+%wp%+1 +backGroundTrans,|
		gui, Font, norm Underline
		gui, add, text, x+%wp%+1 yp +backGroundTrans gediting.deleteString, Убрать
		;gui, add, Text, xs+320 yp, Простейший редактор
		gui, Font, torm, Verdana
		gui, add, button, y350 x10 w130, Применить
		gui, add, button, yp x+%wp% wp, Отмена
		gui, add, button, yp x+%wp%+60 w126, Удалить
		LV_ModifyCol(1,25), LV_ModifyCol(2,25), LV_ModifyCol(3,285), LV_ModifyCol(4,35), LV_ModifyCol(5, 90)
		gui, Show,,% "Изменение бинда #" Change.Index
  }
  editString() {
    msgbox % "edit a string: " this.index
  }
  addString() {

  }
  deleteString() {

  }
}
