/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.RenameDialog : Gtk.Window {
    public FileBase file { get; construct; }
    public OperationManager operation_manager { get; construct; }

    private Gtk.Entry rename_entry;

    public RenameDialog (FileBase file, OperationManager operation_manager) {
        Object (file: file, operation_manager: operation_manager);
    }

    construct {
        var rename_label = new Granite.HeaderLabel (_("Rename file:")) {
            halign = START,
        };

        rename_entry = new Gtk.Entry () {
            text = file.display_name,
            activates_default = true,
        };

        var cancel_button = new Gtk.Button.with_label (_("Cancel")) {
            action_name = "window.close",
        };

        var rename_button = new Gtk.Button.with_label (_("Rename"));
        rename_button.clicked.connect (rename_file);
        rename_button.add_css_class (Granite.CssClass.SUGGESTED);

        var button_box = new Granite.Box (HORIZONTAL, HALF) {
            halign = END,
        };
        button_box.append (cancel_button);
        button_box.append (rename_button);

        var content = new Granite.Box (VERTICAL) {
            margin_start = 12,
            margin_end = 12,
            margin_top = 12,
            margin_bottom = 12,
        };
        content.append (rename_label);
        content.append (rename_entry);
        content.append (button_box);

        titlebar = new Granite.Bin () {
            visible = false,
        };
        child = content;
        default_width = 500;
        default_height = 100;
        resizable = false;
        default_widget = rename_button;
    }

    private void rename_file () {
        operation_manager.rename_file.begin (file.file, rename_entry.text);
        close ();
    }
}
