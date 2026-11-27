/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

[GtkTemplate (ui = "/io/github/leolost2605/paper/ui/note-list.ui")]
public class Paper.NoteList : Granite.Bin {
    public FileList? root_files {
        set {
            if (value == null) {
                stack.remove_all ();
                return;
            }

            stack.splice (0, stack.n_items, { value });
        }
    }

    public FileList? current_files {
        owned get {
            if (stack == null || stack.n_items == 0) {
                return null;
            }

            return (FileList) stack.get_item (stack.n_items - 1);
        }
    }

    private ListStore stack;
    private SimpleAction back_action;

    [GtkChild]
    private unowned Gtk.MultiSelection selection_model;

    private OperationManager operation_manager;

    construct {
        stack = new ListStore (typeof (FileList));
        stack.items_changed.connect (on_stack_changed);

        back_action = new SimpleAction ("back", null);
        back_action.activate.connect (on_back);
        var create_note_action = new SimpleAction ("create-note", new VariantType.maybe (VariantType.STRING));
        create_note_action.activate.connect (create_new_note);
        var create_folder_action = new SimpleAction ("create-folder", new VariantType.maybe (VariantType.STRING));
        create_folder_action.activate.connect (create_new_folder);
        var delete_action = new SimpleAction ("delete-note", null);
        delete_action.activate.connect (delete_note);
        var rename_action = new SimpleAction ("rename-note", null);
        rename_action.activate.connect (rename_file);

        var action_group = new SimpleActionGroup ();
        action_group.add_action (back_action);
        action_group.add_action (create_note_action);
        action_group.add_action (create_folder_action);
        action_group.add_action (delete_action);
        action_group.add_action (rename_action);
        insert_action_group ("note-list", action_group);

        operation_manager = new OperationManager (selection_model);
    }

    private void on_stack_changed () {
        back_action.set_enabled (stack.n_items > 1);
        notify_property ("current-files");
    }

    private void on_back (Variant? param) {
        if (stack.n_items > 1) {
            stack.remove (stack.n_items - 1);
        }
    }

    private void create_new_note (Variant? param) requires (param != null) {
        var parent_file = get_parent_for_creation (param);
        var new_note = parent_file.get_child (Uuid.string_random ());
        operation_manager.create_note.begin (new_note);
    }

    private void create_new_folder (Variant? param) requires (param != null) {
        var parent_file = get_parent_for_creation (param);
        var new_dir = parent_file.get_child (Uuid.string_random ());
        operation_manager.create_directory.begin (new_dir);
    }

    private File get_parent_for_creation (Variant? param) {
        var maybe = param?.get_maybe ();
        if (maybe != null) {
            return File.new_for_uri (maybe.get_string ());
        }

        return File.new_for_uri (current_files?.uri ?? "invalid");
    }

    private void delete_note (Variant? param) requires (param == null) {
        if (selection_model.get_selection ().is_empty ()) {
            return;
        }

        // TODO: Support multi selection
        var first_selected_index = selection_model.get_selection ().get_nth (0);
        var first_selected_row = (Gtk.TreeListRow) selection_model.get_item (first_selected_index);

        var first_selected = (FileBase) first_selected_row.item;

        var message_dialog = new Granite.MessageDialog (
            _("Delete “%s”?").printf (first_selected.display_name),
            _("This can't be undone"),
            new ThemedIcon ("edit-delete"),
            NONE
        ) {
            transient_for = (Gtk.Window) get_root (),
            modal = true,
        };
        message_dialog.set_data ("file", first_selected.file);
        message_dialog.add_button (_("Cancel"), Gtk.ResponseType.CANCEL);
        message_dialog.add_button (_("Delete"), Gtk.ResponseType.OK).add_css_class (Granite.CssClass.DESTRUCTIVE);

        message_dialog.response.connect (on_delete_note_response);
        message_dialog.present ();
    }

    private void on_delete_note_response (Gtk.Dialog dialog, int response) {
        if (response == Gtk.ResponseType.OK) {
            var file = dialog.get_data<File> ("file");
            operation_manager.delete_file.begin (file);
        }

        dialog.destroy ();
    }

    private void rename_file (Variant? param) requires (param == null) {
        if (selection_model.get_selection ().is_empty ()) {
            return;
        }

        // TODO: Support multi selection
        var first_selected_index = selection_model.get_selection ().get_nth (0);
        var first_selected_row = (Gtk.TreeListRow) selection_model.get_item (first_selected_index);

        var first_selected = (FileBase) first_selected_row.item;

        new RenameDialog (first_selected, operation_manager) {
            transient_for = get_root () as Gtk.Window,
            modal = true,
        }.present ();
    }

    [GtkCallback]
    private Gtk.TreeListModel? create_tree_model (ListModel? files) {
        if (files == null) {
            return null;
        }

        return new Gtk.TreeListModel (files, false, false, create_child_model_func);
    }

    private static ListModel? create_child_model_func (Object item) {
        if (!(item is Directory)) {
            return null;
        }

        var directory = (Directory) item;
        directory.load ();

        return directory.children;
    }

    [GtkCallback]
    private void on_note_item_setup (Object obj) {
        var item = (Gtk.ListItem) obj;
        item.child = new NoteListItem ();
    }

    [GtkCallback]
    private void on_note_item_bind (Object obj) {
        var item = (Gtk.ListItem) obj;
        var child = (NoteListItem) item.child;
        child.item = item.item;
    }

    [GtkCallback]
    private void on_activate (Gtk.ListView list_view, uint position) {
        var row = (Gtk.TreeListRow) list_view.model.get_item (position);

        var file = (FileBase) row.item;
        if (file is Note) {
            activate_action_variant (MainWindow.ACTION_PREFIX + MainWindow.OPEN_NOTE_ACTION, new Variant.string (file.uri));
        } else {
            var dir = (Directory) file;
            var file_list = new FileList (dir.display_name, dir.children, dir.uri);
            stack.append (file_list);
        }
    }
}
