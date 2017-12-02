class mainWin {
  create() {
    gui, mainWin: new,,% "DLQ Binder"
    gui, color, white
    gui, font,, verdana
    gui, add, tab3, x-3 y-2 w660 h310 +theme -background, 1|2|3|4
    loop 4 {
      gui, tab,% tabIndex := a_index
      gui, add, text, x10  y32 +backgroundTrans, Клавиша
      gui, add, text, x120 yp +backgroundTrans, Название
      loop 8 {
        func := objBindMethod(editing,"start", ( tabIndex - 1) * 8 + a_index )
        gui, add, edit, x10 yp+30 w100 +readOnly
        gui, add, edit, x115 yp w300 +readOnly
        gui, add, button, x420 yp-1 w200 +hwndButton, Изменить
        GuiControl +G,% button,% func
      }
    }
    gui, tab
    gui, add, dropDownList, x10 y323 gprofiles.change, 1|2
    gui, add, button, x140 y315 w100 h37 gprofiles.save,Сохранить
    gui, add, button, x+wp yp wp hp, Настройки ;TODO
    gui, add, button, x+wp yp wp hp, Помощь ;TODO
    gui, add, button, x520 yp wp hp, Выход ;TODO
  }
  show() {
    this.create()
    gui, mainWin: show, w650 h360
  }
}
