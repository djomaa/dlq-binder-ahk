TASKKILL /F /IM %2
DEL %1
DEL "DLQ Binder.exe"
RENAME "update" "DLQ Binder.exe""
START "" "DLQ Binder.exe"
RD %3 /S /Q
EXIT