blueprint_files = files(
    'ui' / 'main-window.blp',
    'ui' / 'notebook-list-item.blp',
    'ui' / 'welcome-view.blp',
)

blueprints = custom_target(
  'blueprints',
  input: blueprint_files,
  output: '.',
  command: [find_program('blueprint-compiler'), 'batch-compile', '--minify', '@OUTPUT@', '@CURRENT_SOURCE_DIR@', '@INPUT@'],
)

gresource = gnome.compile_resources(
    'as-resources',
    'paper.gresource.xml',
    source_dir: meson.current_source_dir(),
    c_name: 'as',
    dependencies: blueprints
)

icon_sizes = ['16', '24', '32', '48', '64', '128']

foreach i : icon_sizes
    install_data(
        'icons' / i + '.svg',
        install_dir: get_option('datadir') / 'icons' / 'hicolor' / i + 'x' + i / 'apps',
        rename: meson.project_name() + '.svg'
    )
    install_data(
        'icons' / i + '.svg',
        install_dir: get_option('datadir') / 'icons' / 'hicolor' / i + 'x' + i + '@2' / 'apps',
        rename: meson.project_name() + '.svg'
    )
endforeach

install_data(
    'paper.gschema.xml',
    install_dir: get_option('datadir') / 'glib-2.0' / 'schemas',
    rename: meson.project_name() + '.gschema.xml'
)

i18n.merge_file(
    input: 'paper.desktop.in',
    output: meson.project_name() + '.desktop',
    po_dir: meson.project_source_root() / 'po',
    type: 'desktop',
    install: true,
    install_dir: get_option('datadir') / 'applications'
)

i18n.merge_file(
    input: 'paper.metainfo.xml.in',
    output: meson.project_name() + '.metainfo.xml',
    po_dir: meson.project_source_root() / 'po',
    install: true,
    install_dir: get_option('datadir') / 'metainfo'
)
