files = [
    'Application.vala',
    'MainWindow.vala',
    'Model' / 'Notebook.vala',
    'Model' / 'Viewport.vala',
    'Model' / 'Geometry' / 'Line.vala',
    'Model' / 'Geometry' / 'Point.vala',
    'Model' / 'Manipulation' / 'Manipulator.vala',
    'Model' / 'Manipulation' / 'Tool.vala',
    'Model' / 'Manipulation' / 'ToolStore.vala',
    'Model' / 'Manipulation' / 'Tools' / 'Eraser.vala',
    'Model' / 'Manipulation' / 'Tools' / 'Pen.vala',
    'Model' / 'Note' / 'Background.vala',
    'Model' / 'Note' / 'Item.vala',
    'Model' / 'Note' / 'Note.vala',
    'Model' / 'Note' / 'Backgrounds' / 'WhiteBackground.vala',
    'Model' / 'Note' / 'Items' / 'Stroke.vala',
    'Model' / 'Renderer' / 'Renderer.vala',
    'NoteView' / 'NotesList.vala',
    'NoteView' / 'NoteView.vala',
    'NoteView' / 'Canvas' / 'Canvas.vala',
    'NoteView' / 'Canvas' / 'DrawTarget.vala',
    'NoteView' / 'Canvas' / 'InputHandler.vala',
    'NoteView' / 'Canvas' / 'MoveHandler.vala',
    'NoteView' / 'Penbar' / 'Penbar.vala',
    'NoteView' / 'Penbar' / 'PenButton.vala',
    'NoteView' / 'Penbar' / 'PenPopover.vala',
]

# Create a new executable, list the files we want to compile, and install
executable(
    meson.project_name(),
    config_file,
    gresource,
    files,
    dependencies: deps,
    install: true
)
