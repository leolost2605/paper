# project name and programming language
project(
  'io.github.leolost2605.paper',
  'vala', 'c',
  version: '0.1'
)

cc = meson.get_compiler('c')

# Include Gnome and the translations module
gnome = import('gnome')
i18n = import('i18n')

# Set our translation domain
add_global_arguments('-DGETTEXT_PACKAGE="@0@"'.format (meson.project_name()), language:'c')

## Set de config data
config_data = configuration_data()
config_data.set_quoted('LOCALEDIR', get_option('prefix') / get_option('localedir'))
config_data.set_quoted('GETTEXT_PACKAGE', meson.project_name())
config_file = configure_file(
    input: 'src' / 'Config.vala.in',
    output: '@BASENAME@',
    configuration: config_data
)

# List the dependencies we need
deps = [
    dependency('granite-7'),
    dependency('gtk4'),
    dependency('json-glib-1.0'),
    dependency('libadwaita-1'),
    cc.find_library('m'),
    dependency('poppler-glib'),
    dependency('sqlite3'),
]

subdir('data')
subdir('src')
subdir('po')

gnome.post_install(
  glib_compile_schemas: true,
  gtk_update_icon_cache: true,
  update_desktop_database: true,
)
