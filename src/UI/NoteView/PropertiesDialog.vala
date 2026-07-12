/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Paper.PropertiesDialog : Gtk.Window {
    public Content content { get; construct; }

    public PropertiesDialog (Content content) {
        Object (content: content);
    }

    construct {
        var page_format_label = new Granite.HeaderLabel (_("Page Format")) {
            secondary_text = _("Set a custom page format for this note. This will affect how the note is exported and printed.")
        };

        var page_format_switch = new Gtk.Switch () {
            valign = CENTER
        };
        content.page_format.bind_property ("active", page_format_switch, "active", SYNC_CREATE | BIDIRECTIONAL);
        content.page_format.bind_property ("active", page_format_switch, "state", SYNC_CREATE);

        var page_format_header_grid = new Gtk.Grid ();
        page_format_header_grid.add_css_class ("preferences-grid");
        page_format_header_grid.attach (page_format_label, 0, 0);
        page_format_header_grid.attach (page_format_switch, 1, 0);

        var page_format_width_label = new Gtk.Label (_("Width:")) {
            hexpand = true,
            xalign = 0,
        };

        var page_format_width_spin = new Gtk.SpinButton.with_range (0, 1000, 1) {
            valign = CENTER,
        };
        content.page_format.bind_property ("width", page_format_width_spin, "value", SYNC_CREATE | BIDIRECTIONAL);

        var page_format_height_label = new Gtk.Label (_("Height:")) {
            hexpand = true,
            xalign = 0,
        };

        var page_format_height_spin = new Gtk.SpinButton.with_range (0, 1000, 1) {
            valign = CENTER,
        };
        content.page_format.bind_property ("height", page_format_height_spin, "value", SYNC_CREATE | BIDIRECTIONAL);

        var page_format_grid = new Gtk.Grid ();
        page_format_grid.add_css_class ("preferences-grid");
        page_format_grid.attach (page_format_width_label, 0, 0);
        page_format_grid.attach (page_format_width_spin, 1, 0);
        page_format_grid.attach (page_format_height_label, 0, 1);
        page_format_grid.attach (page_format_height_spin, 1, 1);

        var page_format_revealer = new Gtk.Revealer () {
            child = page_format_grid
        };
        content.page_format.bind_property ("active", page_format_revealer, "reveal-child", SYNC_CREATE);

        var page_format_box = new Granite.Box (VERTICAL, SINGLE);
        page_format_box.append (page_format_header_grid);
        page_format_box.append (page_format_revealer);

        var view_mode_label = new Granite.HeaderLabel (_("View Mode")) {
            secondary_text = _("Set a custom view mode for this note. This will affect how the note looks while editing, but not how it is exported or printed.")
        };

        var view_mode_dropdown = new Gtk.DropDown (null, null) {
            valign = CENTER,
        };

        var view_mode_grid = new Gtk.Grid ();
        view_mode_grid.add_css_class ("preferences-grid");
        view_mode_grid.attach (view_mode_label, 0, 0);
        view_mode_grid.attach (view_mode_dropdown, 1, 0);

        var pattern_label = new Granite.HeaderLabel (_("Pattern")) {
            secondary_text = _("Set a custom pattern for this note. This will affect how the note looks while editing, but not how it is exported or printed.")
        };

        var pattern_switch = new Gtk.Switch () {
            valign = CENTER
        };
        content.pattern.bind_property ("active", pattern_switch, "active", SYNC_CREATE | BIDIRECTIONAL);
        content.pattern.bind_property ("active", pattern_switch, "state", SYNC_CREATE);

        var pattern_header_grid = new Gtk.Grid ();
        pattern_header_grid.add_css_class ("preferences-grid");
        pattern_header_grid.attach (pattern_label, 0, 0);
        pattern_header_grid.attach (pattern_switch, 1, 0);

        var pattern_style_label = new Gtk.Label (_("Style")) {
            hexpand = true,
            xalign = 0,
        };

        var patterns_model = new Adw.EnumListModel (typeof (Pattern.Style));

        var name_expression = new Gtk.PropertyExpression (typeof (Adw.EnumListItem), null, "nick");

        var pattern_style_dropdown = new Gtk.DropDown (patterns_model, name_expression) {
            valign = CENTER,
        };
        content.pattern.bind_property ("style", pattern_style_dropdown, "selected", SYNC_CREATE | BIDIRECTIONAL);

        var pattern_width_label = new Gtk.Label (_("Width:")) {
            hexpand = true,
            xalign = 0,
        };

        var pattern_width_spin = new Gtk.SpinButton.with_range (0, 1000, 1) {
            valign = CENTER,
        };
        content.pattern.bind_property ("width", pattern_width_spin, "value", SYNC_CREATE | BIDIRECTIONAL);

        var pattern_height_label = new Gtk.Label (_("Height:")) {
            hexpand = true,
            xalign = 0,
        };

        var pattern_height_spin = new Gtk.SpinButton.with_range (0, 1000, 1) {
            valign = CENTER,
        };
        content.pattern.bind_property ("height", pattern_height_spin, "value", SYNC_CREATE | BIDIRECTIONAL);

        var pattern_grid = new Gtk.Grid ();
        pattern_grid.add_css_class ("preferences-grid");
        pattern_grid.attach (pattern_style_label, 0, 0);
        pattern_grid.attach (pattern_style_dropdown, 1, 0);
        pattern_grid.attach (pattern_width_label, 0, 1);
        pattern_grid.attach (pattern_width_spin, 1, 1);
        pattern_grid.attach (pattern_height_label, 0, 2);
        pattern_grid.attach (pattern_height_spin, 1, 2);

        var pattern_revealer = new Gtk.Revealer () {
            child = pattern_grid
        };
        content.pattern.bind_property ("active", pattern_revealer, "reveal-child", SYNC_CREATE);

        var pattern_box = new Granite.Box (VERTICAL, SINGLE);
        pattern_box.append (pattern_header_grid);
        pattern_box.append (pattern_revealer);

        var origin_indicator_label = new Granite.HeaderLabel (_("Show Origin Indicator")) {
            secondary_text = _("Show a small indicator at the origin of the note."),
            hexpand = true
        };

        var origin_indicator_switch = new Gtk.Switch () {
            valign = CENTER
        };
        content.origin_indicator.bind_property ("active", origin_indicator_switch, "active", SYNC_CREATE | BIDIRECTIONAL);
        content.origin_indicator.bind_property ("active", origin_indicator_switch, "state", SYNC_CREATE);

        var origin_indicator_grid = new Gtk.Grid ();
        origin_indicator_grid.add_css_class ("preferences-grid");
        origin_indicator_grid.attach (origin_indicator_label, 0, 0);
        origin_indicator_grid.attach (origin_indicator_switch, 1, 0);

        var main_box = new Granite.Box (VERTICAL, DOUBLE) {
            margin_start = 12,
            margin_end = 12,
            margin_top = 12,
            margin_bottom = 12,
        };
        main_box.append (page_format_box);
        main_box.append (view_mode_grid);
        main_box.append (pattern_box);
        main_box.append (origin_indicator_grid);

        var scrolled_window = new Gtk.ScrolledWindow () {
            child = main_box,
            hscrollbar_policy = NEVER,
        };

        var toolbar_view = new Adw.ToolbarView () {
            content = scrolled_window,
        };
        toolbar_view.add_top_bar (new Adw.HeaderBar ());

        child = toolbar_view;
        title = _("Document Properties");
        titlebar = new Gtk.Grid () { visible = false };
        default_width = 400;
        default_height = 500;
    }
}
