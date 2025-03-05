#requires AutoHotkey v2.0
#include Log.ahk

; imagesPath := "../img/base64-embedded-images/"

global base64images := Map(
	"transparent", "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABAQMAAAAl21bKAAAAA1BMVEUAAACnej3aAAAAAXRSTlMAQObYZgAAAApJREFUCNdjYAAAAAIAAeIhvDMAAAAASUVORK5CYII=",
	; 9px image width, 7px arrow width
	"arrow_white_9px", "iVBORw0KGgoAAAANSUhEUgAAAAkAAAAJCAYAAADgkQYQAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA3ZpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDkuMS1jMDAyIDc5LmRiYTNkYTNiNSwgMjAyMy8xMi8xNS0xMDo0MjozNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDo0Y2RhMzdhYy1jYjBlLTkzNDEtODA2Ni0yOGVmZDRmNDkwZTMiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6OUY5NkE3NjQyM0MxMTFFRjlDNzVFNDQ0NTQwRkI0RDQiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6OUY5NkE3NjMyM0MxMTFFRjlDNzVFNDQ0NTQwRkI0RDQiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI1LjYgKFdpbmRvd3MpIj4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6MzVlOWQ4NDktNzdmYy0xMDRkLWI0NWYtNmY4NzZkZGM0YTIyIiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOjRjZGEzN2FjLWNiMGUtOTM0MS04MDY2LTI4ZWZkNGY0OTBlMyIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/Pk6FwAYAAABVSURBVHjajI0BCsAwCAOT/rL9/z+cbs2oboUGghoPhZlBdnV3ND3lFbBnSOAHkFbwF6ggJ4CdSKJ5HdGE63Jmg7riQboYgM831XCgFXrf6o0WlwADAKgRYPvybfeRAAAAAElFTkSuQmCC",
	"arrow_red_9px", "iVBORw0KGgoAAAANSUhEUgAAAAkAAAAJCAYAAADgkQYQAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA3ZpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDkuMS1jMDAyIDc5LmRiYTNkYTNiNSwgMjAyMy8xMi8xNS0xMDo0MjozNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDo0Y2RhMzdhYy1jYjBlLTkzNDEtODA2Ni0yOGVmZDRmNDkwZTMiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6OUZBQzFCRjEyM0MxMTFFRjlDNzVFNDQ0NTQwRkI0RDQiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6OUZBOUI5QUEyM0MxMTFFRjlDNzVFNDQ0NTQwRkI0RDQiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI1LjYgKFdpbmRvd3MpIj4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6MzVlOWQ4NDktNzdmYy0xMDRkLWI0NWYtNmY4NzZkZGM0YTIyIiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOjRjZGEzN2FjLWNiMGUtOTM0MS04MDY2LTI4ZWZkNGY0OTBlMyIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PtG5M/EAAABDSURBVHjaYvz//z8DIcACIj4yMiKLgXTBBfiBhjChafqPRoMBExYFGHwmHApQFLJAOYxYFDNisw4nIEoRIzHhBBBgANMiEQopu/+SAAAAAElFTkSuQmCC",
	"arrow_green_9px", "iVBORw0KGgoAAAANSUhEUgAAAAkAAAAJCAYAAADgkQYQAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA3ZpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDkuMS1jMDAyIDc5LmRiYTNkYTNiNSwgMjAyMy8xMi8xNS0xMDo0MjozNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDo0Y2RhMzdhYy1jYjBlLTkzNDEtODA2Ni0yOGVmZDRmNDkwZTMiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6MTlGMzhDQkEyM0MzMTFFRjk5RkM4ODM2ODc5NUY1QUEiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6MTlGMzhDQjkyM0MzMTFFRjk5RkM4ODM2ODc5NUY1QUEiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI1LjYgKFdpbmRvd3MpIj4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6MzVlOWQ4NDktNzdmYy0xMDRkLWI0NWYtNmY4NzZkZGM0YTIyIiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOjRjZGEzN2FjLWNiMGUtOTM0MS04MDY2LTI4ZWZkNGY0OTBlMyIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PkHOFRQAAAA9SURBVHjaYvz//z8DIcCELsA4h/E/XkUwBegKmXCZgMxnwmUFisnIDkdW/D/lPyNOhxPlO6zWEhNOAAEGAGnYGFIcFGGPAAAAAElFTkSuQmCC",
	"arrow_blue_9px", "iVBORw0KGgoAAAANSUhEUgAAAAkAAAAJCAYAAADgkQYQAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA3ZpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDkuMS1jMDAyIDc5LmRiYTNkYTNiNSwgMjAyMy8xMi8xNS0xMDo0MjozNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDo0Y2RhMzdhYy1jYjBlLTkzNDEtODA2Ni0yOGVmZDRmNDkwZTMiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6RjNEMzU0NUMyM0MyMTFFRjg1OEFCMDZDRjNFQTJGNkYiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6RjNEMzU0NUIyM0MyMTFFRjg1OEFCMDZDRjNFQTJGNkYiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI1LjYgKFdpbmRvd3MpIj4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6MzVlOWQ4NDktNzdmYy0xMDRkLWI0NWYtNmY4NzZkZGM0YTIyIiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOjRjZGEzN2FjLWNiMGUtOTM0MS04MDY2LTI4ZWZkNGY0OTBlMyIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PgU9tU0AAABESURBVHjaYvz//z8DIcACIlTzUMRAuhhhnNuTGBiY0DT9R6PBgAmLAgw+Ew4FKApZoBxGLIoZsVmHExCliJGYcAIIMADDkxAKQ2rHlAAAAABJRU5ErkJggg==",
	; 12px image width, 10px arrow width
	"arrow_white_12px", "iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAACXBIWXMAAAsTAAALEwEAmpwYAAAGmWlUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgOS4xLWMwMDIgNzkuYTZhNjM5NiwgMjAyNC8wMy8xMi0wNzo0ODoyMyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczpzdEV2dD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlRXZlbnQjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyIgeG1sbnM6cGhvdG9zaG9wPSJodHRwOi8vbnMuYWRvYmUuY29tL3Bob3Rvc2hvcC8xLjAvIiB4bXBNTTpPcmlnaW5hbERvY3VtZW50SUQ9InhtcC5kaWQ6NGNkYTM3YWMtY2IwZS05MzQxLTgwNjYtMjhlZmQ0ZjQ5MGUzIiB4bXBNTTpEb2N1bWVudElEPSJ4bXAuZGlkOjYyMTUwQkU5MjNDMzExRUZBREJFQjYyNkJBQUIzRTY1IiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOmIwYmRjOTBlLWE5OTgtZGM0Mi1hZTgxLWM5YTU4N2UxYzhjOSIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgMjUuNiAoV2luZG93cykiIHhtcDpDcmVhdGVEYXRlPSIyMDI1LTAyLTI2VDEzOjM4OjA4LTA4OjAwIiB4bXA6TW9kaWZ5RGF0ZT0iMjAyNS0wMi0yNlQxNDowNjoxNi0wODowMCIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyNS0wMi0yNlQxNDowNjoxNi0wODowMCIgZGM6Zm9ybWF0PSJpbWFnZS9wbmciIHBob3Rvc2hvcDpDb2xvck1vZGU9IjMiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDozNWU5ZDg0OS03N2ZjLTEwNGQtYjQ1Zi02Zjg3NmRkYzRhMjIiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6NGNkYTM3YWMtY2IwZS05MzQxLTgwNjYtMjhlZmQ0ZjQ5MGUzIi8+IDx4bXBNTTpIaXN0b3J5PiA8cmRmOlNlcT4gPHJkZjpsaSBzdEV2dDphY3Rpb249InNhdmVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOjM4MTQzYzk2LTFiY2ItYjY0Ny1iZThlLWRkNjNjZDg3MmI5OSIgc3RFdnQ6d2hlbj0iMjAyNS0wMi0yNlQxMzo0MjozNC0wODowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDI1LjkgKFdpbmRvd3MpIiBzdEV2dDpjaGFuZ2VkPSIvIi8+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJzYXZlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDpiMGJkYzkwZS1hOTk4LWRjNDItYWU4MS1jOWE1ODdlMWM4YzkiIHN0RXZ0OndoZW49IjIwMjUtMDItMjZUMTQ6MDY6MTYtMDg6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCAyNS45IChXaW5kb3dzKSIgc3RFdnQ6Y2hhbmdlZD0iLyIvPiA8L3JkZjpTZXE+IDwveG1wTU06SGlzdG9yeT4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz5JvylbAAAAbklEQVQokaWSUQrAIAxDk+EZuzPmlNnH3LCd6McCQrEvUqO0jSqSBgDbrL02gyW9dTW1GRwRaS+ZbKOPZUmukuQb69wKnpm2cDUBQPTiOSVp7AEIjrH2C9bUUrzH5xE2+m04SWJcAM404uxrrHQBjd6r0ZaLwd8AAAAASUVORK5CYII=",
	"arrow_red_12px", "iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA3ZpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDkuMS1jMDAyIDc5LmRiYTNkYTNiNSwgMjAyMy8xMi8xNS0xMDo0MjozNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDo0Y2RhMzdhYy1jYjBlLTkzNDEtODA2Ni0yOGVmZDRmNDkwZTMiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6OUZBNEY1MUEyM0MxMTFFRjlDNzVFNDQ0NTQwRkI0RDQiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6OUZBNEY1MTkyM0MxMTFFRjlDNzVFNDQ0NTQwRkI0RDQiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI1LjYgKFdpbmRvd3MpIj4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6MzVlOWQ4NDktNzdmYy0xMDRkLWI0NWYtNmY4NzZkZGM0YTIyIiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOjRjZGEzN2FjLWNiMGUtOTM0MS04MDY2LTI4ZWZkNGY0OTBlMyIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PgJ+bhsAAABfSURBVHjaYvz//z8DKYAFRHxkZEQX3wSl/ZAF+YGGM2ExBKTYF4o3oUsy4VAMAxiamPAoxqqJiYBiDE2M6KEEDID/aB5lxOcHDAAKQeRQZGIgEZCsgZHUmCbZBoAAAwBSZRrtE2xryQAAAABJRU5ErkJggg==",
	"arrow_green_12px", "iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA3ZpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDkuMS1jMDAyIDc5LmRiYTNkYTNiNSwgMjAyMy8xMi8xNS0xMDo0MjozNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDo0Y2RhMzdhYy1jYjBlLTkzNDEtODA2Ni0yOGVmZDRmNDkwZTMiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6MTlFRUM4MTgyM0MzMTFFRjk5RkM4ODM2ODc5NUY1QUEiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6MTlFRUM4MTcyM0MzMTFFRjk5RkM4ODM2ODc5NUY1QUEiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI1LjYgKFdpbmRvd3MpIj4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6MzVlOWQ4NDktNzdmYy0xMDRkLWI0NWYtNmY4NzZkZGM0YTIyIiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOjRjZGEzN2FjLWNiMGUtOTM0MS04MDY2LTI4ZWZkNGY0OTBlMyIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/Pr9D0iUAAABOSURBVHjaYvz//z8DKYAJmyDjHMZNIEyUBqhCXxDGpokJh2IYwNDEhEcxVk1MBBRjaGJEDyWgBIrA/5T/jARDieRgpaoGRqrEND4AEGAAo+4clZiKLkEAAAAASUVORK5CYII=",
	"arrow_blue_12px", "iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA3ZpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDkuMS1jMDAyIDc5LmRiYTNkYTNiNSwgMjAyMy8xMi8xNS0xMDo0MjozNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDo0Y2RhMzdhYy1jYjBlLTkzNDEtODA2Ni0yOGVmZDRmNDkwZTMiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6RjNDRThGQkQyM0MyMTFFRjg1OEFCMDZDRjNFQTJGNkYiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6RjNDRThGQkMyM0MyMTFFRjg1OEFCMDZDRjNFQTJGNkYiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI1LjYgKFdpbmRvd3MpIj4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6MzVlOWQ4NDktNzdmYy0xMDRkLWI0NWYtNmY4NzZkZGM0YTIyIiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOjRjZGEzN2FjLWNiMGUtOTM0MS04MDY2LTI4ZWZkNGY0OTBlMyIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/Pqy+8sQAAABTSURBVHjaYvz//z8DKYAFRKjmYYhvgtJ+yIK3JzEwMGExBKTYF4o3oUsy4VAMAxiamPAoxqqJiYBiDE0sWDyHHmyM+PxAENBeAyOpMU2yDQABBgCe+xJbzIQ5JwAAAABJRU5ErkJggg==",
	; 9px image width, 5px circle  width
	"circle_red_9px", "iVBORw0KGgoAAAANSUhEUgAAAAkAAAAJCAYAAADgkQYQAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA3ZpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDkuMS1jMDAyIDc5LmRiYTNkYTNiNSwgMjAyMy8xMi8xNS0xMDo0MjozNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDo0Y2RhMzdhYy1jYjBlLTkzNDEtODA2Ni0yOGVmZDRmNDkwZTMiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6OUZBOUI5QTcyM0MxMTFFRjlDNzVFNDQ0NTQwRkI0RDQiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6OUZBOUI5QTYyM0MxMTFFRjlDNzVFNDQ0NTQwRkI0RDQiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI1LjYgKFdpbmRvd3MpIj4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6MzVlOWQ4NDktNzdmYy0xMDRkLWI0NWYtNmY4NzZkZGM0YTIyIiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOjRjZGEzN2FjLWNiMGUtOTM0MS04MDY2LTI4ZWZkNGY0OTBlMyIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/Pnw0+9IAAABPSURBVHjaYvz//z8DIcDEQARAUfSRkXETEP8H0SiqQNaB8AcGhk1A/B8Jb4LJMcLcBDIB3Rr+//8Z0a3bjKZmM4Z1aFZuQhZnpFoQAAQYADM+P8ufPPnPAAAAAElFTkSuQmCC",
	"circle_green_9px", "iVBORw0KGgoAAAANSUhEUgAAAAkAAAAJCAYAAADgkQYQAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA3ZpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDkuMS1jMDAyIDc5LmRiYTNkYTNiNSwgMjAyMy8xMi8xNS0xMDo0MjozNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDo0Y2RhMzdhYy1jYjBlLTkzNDEtODA2Ni0yOGVmZDRmNDkwZTMiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6MTlGMzhDQjYyM0MzMTFFRjk5RkM4ODM2ODc5NUY1QUEiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6MTlGMzhDQjUyM0MzMTFFRjk5RkM4ODM2ODc5NUY1QUEiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI1LjYgKFdpbmRvd3MpIj4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6MzVlOWQ4NDktNzdmYy0xMDRkLWI0NWYtNmY4NzZkZGM0YTIyIiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOjRjZGEzN2FjLWNiMGUtOTM0MS04MDY2LTI4ZWZkNGY0OTBlMyIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PoNi/LQAAABKSURBVHjaYvz//z8DIcDEQARAUcQ4h3ETEP8H0VgVQSV8oVxfZIXIJvmi2eKLTdFmNEUIPsh3MMwwm2ETEP8H0cjijFQLAoAAAwBkBiWi1M0JOgAAAABJRU5ErkJggg==",
	"circle_blue_9px", "iVBORw0KGgoAAAANSUhEUgAAAAkAAAAJCAYAAADgkQYQAAAAGXRFWHRTb2Z0d2FyZQBBZG9iZSBJbWFnZVJlYWR5ccllPAAAA3ZpVFh0WE1MOmNvbS5hZG9iZS54bXAAAAAAADw/eHBhY2tldCBiZWdpbj0i77u/IiBpZD0iVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkIj8+IDx4OnhtcG1ldGEgeG1sbnM6eD0iYWRvYmU6bnM6bWV0YS8iIHg6eG1wdGs9IkFkb2JlIFhNUCBDb3JlIDkuMS1jMDAyIDc5LmRiYTNkYTNiNSwgMjAyMy8xMi8xNS0xMDo0MjozNyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtcE1NOk9yaWdpbmFsRG9jdW1lbnRJRD0ieG1wLmRpZDo0Y2RhMzdhYy1jYjBlLTkzNDEtODA2Ni0yOGVmZDRmNDkwZTMiIHhtcE1NOkRvY3VtZW50SUQ9InhtcC5kaWQ6RjNEMzU0NTgyM0MyMTFFRjg1OEFCMDZDRjNFQTJGNkYiIHhtcE1NOkluc3RhbmNlSUQ9InhtcC5paWQ6RjNEMzU0NTcyM0MyMTFFRjg1OEFCMDZDRjNFQTJGNkYiIHhtcDpDcmVhdG9yVG9vbD0iQWRvYmUgUGhvdG9zaG9wIDI1LjYgKFdpbmRvd3MpIj4gPHhtcE1NOkRlcml2ZWRGcm9tIHN0UmVmOmluc3RhbmNlSUQ9InhtcC5paWQ6MzVlOWQ4NDktNzdmYy0xMDRkLWI0NWYtNmY4NzZkZGM0YTIyIiBzdFJlZjpkb2N1bWVudElEPSJ4bXAuZGlkOjRjZGEzN2FjLWNiMGUtOTM0MS04MDY2LTI4ZWZkNGY0OTBlMyIvPiA8L3JkZjpEZXNjcmlwdGlvbj4gPC9yZGY6UkRGPiA8L3g6eG1wbWV0YT4gPD94cGFja2V0IGVuZD0iciI/PtcZQw0AAABJSURBVHjaYvz//z8DIcDEQARggTFU88DUJiD2BeLNQOx3exKmSTAFDFB6EzbrfNFs8cWmaDOaos3YFPkhSWyG8sGAkWpBABBgANUWEA3dJYkxAAAAAElFTkSuQmCC",
	; 12px image width, 6px circle width
	"circle_red_12px", "iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAACXBIWXMAAAsTAAALEwEAmpwYAAAGq2lUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgOS4xLWMwMDIgNzkuYTZhNjM5NiwgMjAyNC8wMy8xMi0wNzo0ODoyMyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczpzdEV2dD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlRXZlbnQjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyIgeG1sbnM6cGhvdG9zaG9wPSJodHRwOi8vbnMuYWRvYmUuY29tL3Bob3Rvc2hvcC8xLjAvIiB4bXBNTTpPcmlnaW5hbERvY3VtZW50SUQ9InhtcC5kaWQ6NGNkYTM3YWMtY2IwZS05MzQxLTgwNjYtMjhlZmQ0ZjQ5MGUzIiB4bXBNTTpEb2N1bWVudElEPSJhZG9iZTpkb2NpZDpwaG90b3Nob3A6Zjg3MTNjNjEtNjFiYy0wZDQ2LWJmOGMtY2Y2NDk4NjllMzNlIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOjY0ODYwMjYyLWM2YzItNTA0Mi1hZDI1LTFlOWEwNDg1ZjJhNiIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgMjUuNiAoV2luZG93cykiIHhtcDpDcmVhdGVEYXRlPSIyMDI0LTA2LTA1VDIyOjA5OjQ2LTA3OjAwIiB4bXA6TW9kaWZ5RGF0ZT0iMjAyNS0wMi0yN1QxMjoyMzowOS0wODowMCIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyNS0wMi0yN1QxMjoyMzowOS0wODowMCIgZGM6Zm9ybWF0PSJpbWFnZS9wbmciIHBob3Rvc2hvcDpDb2xvck1vZGU9IjMiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDozNWU5ZDg0OS03N2ZjLTEwNGQtYjQ1Zi02Zjg3NmRkYzRhMjIiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6NGNkYTM3YWMtY2IwZS05MzQxLTgwNjYtMjhlZmQ0ZjQ5MGUzIi8+IDx4bXBNTTpIaXN0b3J5PiA8cmRmOlNlcT4gPHJkZjpsaSBzdEV2dDphY3Rpb249InNhdmVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOjg3YjhmMzY2LTk1MTEtN2Q0Ny1iYWFiLTg2NDQ4ODlmY2ZjZCIgc3RFdnQ6d2hlbj0iMjAyNS0wMi0yNlQyMDozMzo0My0wODowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDI1LjkgKFdpbmRvd3MpIiBzdEV2dDpjaGFuZ2VkPSIvIi8+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJzYXZlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDo2NDg2MDI2Mi1jNmMyLTUwNDItYWQyNS0xZTlhMDQ4NWYyYTYiIHN0RXZ0OndoZW49IjIwMjUtMDItMjdUMTI6MjM6MDktMDg6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCAyNS45IChXaW5kb3dzKSIgc3RFdnQ6Y2hhbmdlZD0iLyIvPiA8L3JkZjpTZXE+IDwveG1wTU06SGlzdG9yeT4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz7Id1I4AAAAVUlEQVQokc2RQQrAMAgEd/qBftn+OL5geykhkVxCLhX2IiMyim3t1LVFHw8kKCES/CUS5gnbPU2KJrkkRoZROmF5gdvua46lnwUz94pD9YhWGP73uBdrlU3RVcqQaQAAAABJRU5ErkJggg==",
	"circle_green_12px", "iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAACXBIWXMAAAsTAAALEwEAmpwYAAAGq2lUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgOS4xLWMwMDIgNzkuYTZhNjM5NiwgMjAyNC8wMy8xMi0wNzo0ODoyMyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczpzdEV2dD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlRXZlbnQjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyIgeG1sbnM6cGhvdG9zaG9wPSJodHRwOi8vbnMuYWRvYmUuY29tL3Bob3Rvc2hvcC8xLjAvIiB4bXBNTTpPcmlnaW5hbERvY3VtZW50SUQ9InhtcC5kaWQ6NGNkYTM3YWMtY2IwZS05MzQxLTgwNjYtMjhlZmQ0ZjQ5MGUzIiB4bXBNTTpEb2N1bWVudElEPSJhZG9iZTpkb2NpZDpwaG90b3Nob3A6MTliYTYxNjAtZjE5Ny1hNjQzLWIzNmMtMDAzMTRhZDVlYjAzIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOjU2Y2E2MjZiLTA5ZDMtMjc0NS05MmZkLWQ4YzdjYTM1NjZhZSIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgMjUuNiAoV2luZG93cykiIHhtcDpDcmVhdGVEYXRlPSIyMDI0LTA2LTA1VDIyOjA5OjQ2LTA3OjAwIiB4bXA6TW9kaWZ5RGF0ZT0iMjAyNS0wMi0yN1QxMjoyMjoxNi0wODowMCIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyNS0wMi0yN1QxMjoyMjoxNi0wODowMCIgZGM6Zm9ybWF0PSJpbWFnZS9wbmciIHBob3Rvc2hvcDpDb2xvck1vZGU9IjMiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDozNWU5ZDg0OS03N2ZjLTEwNGQtYjQ1Zi02Zjg3NmRkYzRhMjIiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6NGNkYTM3YWMtY2IwZS05MzQxLTgwNjYtMjhlZmQ0ZjQ5MGUzIi8+IDx4bXBNTTpIaXN0b3J5PiA8cmRmOlNlcT4gPHJkZjpsaSBzdEV2dDphY3Rpb249InNhdmVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOjg3YjhmMzY2LTk1MTEtN2Q0Ny1iYWFiLTg2NDQ4ODlmY2ZjZCIgc3RFdnQ6d2hlbj0iMjAyNS0wMi0yNlQyMDozMzo0My0wODowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDI1LjkgKFdpbmRvd3MpIiBzdEV2dDpjaGFuZ2VkPSIvIi8+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJzYXZlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDo1NmNhNjI2Yi0wOWQzLTI3NDUtOTJmZC1kOGM3Y2EzNTY2YWUiIHN0RXZ0OndoZW49IjIwMjUtMDItMjdUMTI6MjI6MTYtMDg6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCAyNS45IChXaW5kb3dzKSIgc3RFdnQ6Y2hhbmdlZD0iLyIvPiA8L3JkZjpTZXE+IDwveG1wTU06SGlzdG9yeT4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz4V5gy5AAAAW0lEQVQoka2QUQ6AMAhDH8aj7h7CPXZX/FkiW5hmi/2CpgWKuDsrOJbUO4YzNlIFQIGrUQaol+fscUMU02rthsbQUiX9gBeX2YZPjAZLNB2XZYgC4y3Dzkn/G26aRBcRbOYNOAAAAABJRU5ErkJggg==",
	"circle_blue_12px", "iVBORw0KGgoAAAANSUhEUgAAAAwAAAAMCAYAAABWdVznAAAACXBIWXMAAAsTAAALEwEAmpwYAAAGq2lUWHRYTUw6Y29tLmFkb2JlLnhtcAAAAAAAPD94cGFja2V0IGJlZ2luPSLvu78iIGlkPSJXNU0wTXBDZWhpSHpyZVN6TlRjemtjOWQiPz4gPHg6eG1wbWV0YSB4bWxuczp4PSJhZG9iZTpuczptZXRhLyIgeDp4bXB0az0iQWRvYmUgWE1QIENvcmUgOS4xLWMwMDIgNzkuYTZhNjM5NiwgMjAyNC8wMy8xMi0wNzo0ODoyMyAgICAgICAgIj4gPHJkZjpSREYgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIj4gPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9IiIgeG1sbnM6eG1wTU09Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8iIHhtbG5zOnN0UmVmPSJodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvc1R5cGUvUmVzb3VyY2VSZWYjIiB4bWxuczpzdEV2dD0iaHR0cDovL25zLmFkb2JlLmNvbS94YXAvMS4wL3NUeXBlL1Jlc291cmNlRXZlbnQjIiB4bWxuczp4bXA9Imh0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC8iIHhtbG5zOmRjPSJodHRwOi8vcHVybC5vcmcvZGMvZWxlbWVudHMvMS4xLyIgeG1sbnM6cGhvdG9zaG9wPSJodHRwOi8vbnMuYWRvYmUuY29tL3Bob3Rvc2hvcC8xLjAvIiB4bXBNTTpPcmlnaW5hbERvY3VtZW50SUQ9InhtcC5kaWQ6NGNkYTM3YWMtY2IwZS05MzQxLTgwNjYtMjhlZmQ0ZjQ5MGUzIiB4bXBNTTpEb2N1bWVudElEPSJhZG9iZTpkb2NpZDpwaG90b3Nob3A6OThhNWExNjktYzQ4NS1lNjQxLWI3MmMtMGQyNGI1YmNiODRjIiB4bXBNTTpJbnN0YW5jZUlEPSJ4bXAuaWlkOmQ1M2MzN2IzLTEzMjctMWE0Yi1hYWM3LWI4ODIyN2FiZjQ1NyIgeG1wOkNyZWF0b3JUb29sPSJBZG9iZSBQaG90b3Nob3AgMjUuNiAoV2luZG93cykiIHhtcDpDcmVhdGVEYXRlPSIyMDI0LTA2LTA1VDIyOjA5OjQ2LTA3OjAwIiB4bXA6TW9kaWZ5RGF0ZT0iMjAyNS0wMi0yNlQyMDozMzo0My0wODowMCIgeG1wOk1ldGFkYXRhRGF0ZT0iMjAyNS0wMi0yNlQyMDozMzo0My0wODowMCIgZGM6Zm9ybWF0PSJpbWFnZS9wbmciIHBob3Rvc2hvcDpDb2xvck1vZGU9IjMiPiA8eG1wTU06RGVyaXZlZEZyb20gc3RSZWY6aW5zdGFuY2VJRD0ieG1wLmlpZDozNWU5ZDg0OS03N2ZjLTEwNGQtYjQ1Zi02Zjg3NmRkYzRhMjIiIHN0UmVmOmRvY3VtZW50SUQ9InhtcC5kaWQ6NGNkYTM3YWMtY2IwZS05MzQxLTgwNjYtMjhlZmQ0ZjQ5MGUzIi8+IDx4bXBNTTpIaXN0b3J5PiA8cmRmOlNlcT4gPHJkZjpsaSBzdEV2dDphY3Rpb249InNhdmVkIiBzdEV2dDppbnN0YW5jZUlEPSJ4bXAuaWlkOjg3YjhmMzY2LTk1MTEtN2Q0Ny1iYWFiLTg2NDQ4ODlmY2ZjZCIgc3RFdnQ6d2hlbj0iMjAyNS0wMi0yNlQyMDozMzo0My0wODowMCIgc3RFdnQ6c29mdHdhcmVBZ2VudD0iQWRvYmUgUGhvdG9zaG9wIDI1LjkgKFdpbmRvd3MpIiBzdEV2dDpjaGFuZ2VkPSIvIi8+IDxyZGY6bGkgc3RFdnQ6YWN0aW9uPSJzYXZlZCIgc3RFdnQ6aW5zdGFuY2VJRD0ieG1wLmlpZDpkNTNjMzdiMy0xMzI3LTFhNGItYWFjNy1iODgyMjdhYmY0NTciIHN0RXZ0OndoZW49IjIwMjUtMDItMjZUMjA6MzM6NDMtMDg6MDAiIHN0RXZ0OnNvZnR3YXJlQWdlbnQ9IkFkb2JlIFBob3Rvc2hvcCAyNS45IChXaW5kb3dzKSIgc3RFdnQ6Y2hhbmdlZD0iLyIvPiA8L3JkZjpTZXE+IDwveG1wTU06SGlzdG9yeT4gPC9yZGY6RGVzY3JpcHRpb24+IDwvcmRmOlJERj4gPC94OnhtcG1ldGE+IDw/eHBhY2tldCBlbmQ9InIiPz4FarcEAAAAT0lEQVQokWP8//8/AymAiSTV5GhgQRdQzWNoYGBgqIdyG29PYmjAaQOaYgYGBoZ6qBhOJ9UzYAIUMYo93YhFDYoYigaoB5EVYHiacfBFHAD1hhQTX9h1rgAAAABJRU5ErkJggg==",
)

UseBase64Image(name := "") {
	if (!name or name == "")
		return { image: 0, name: name }

	if base64images.Has(name) {
		; exact name match
		image := { image: CleanBase64(base64images.Get(name)), name: name }
		return image
	} else {
		; starts with name
		for key, value in base64images {
			if key ~= "^" . name { ; regex match for starting with...
				image := { image: CleanBase64(value), name: key }
				return image
			}
		}
	}
	return { image: 0, name: name }
}

CleanBase64(b64str) {
	if InStr(b64str, ",") {
		parts := StrSplit(b64str, ",", 2)
		if parts.Length == 2 and InStr(parts[1], "data") and StrLen(parts[2]) > 2
			return parts[2]
	}
	return b64str
}