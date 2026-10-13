/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

[GtkTemplate (ui = "/io/github/leolost2605/paper/ui/welcome-view.ui")]
public class Paper.WelcomeView : Adw.NavigationPage {
    public NotebookManager notebook_manager { get; construct; }

    [GtkChild]
    private unowned Gtk.SingleSelection notebook_selection;
    [GtkChild]
    private unowned Gtk.MultiSelection selection_model;

    private OperationManager operation_manager;

    public WelcomeView (NotebookManager notebook_manager) {
        Object (notebook_manager: notebook_manager);
    }

    construct {
        operation_manager = new OperationManager (selection_model);

        var create_note_action = new SimpleAction ("create-note", new VariantType.maybe (VariantType.STRING));
        create_note_action.activate.connect (create_new_note);
        var create_folder_action = new SimpleAction ("create-folder", new VariantType.maybe (VariantType.STRING));
        create_folder_action.activate.connect (create_new_folder);
        var delete_action = new SimpleAction ("delete-note", null);
        delete_action.activate.connect (delete_note);
        var rename_action = new SimpleAction ("rename-note", null);
        rename_action.activate.connect (rename_file);

        var action_group = new SimpleActionGroup ();
        action_group.add_action (create_note_action);
        action_group.add_action (create_folder_action);
        action_group.add_action (delete_action);
        action_group.add_action (rename_action);
        insert_action_group ("library", action_group);
    }

    private void create_new_note (Variant? param) requires (param != null) {
        var parent_uri = get_parent_uri_for_creation ();

        var maybe = param.get_maybe ();
        if (maybe != null) {
            parent_uri = maybe.get_string ();
        }

        var parent_file = File.new_for_uri (parent_uri);
        var new_note = parent_file.get_child (Uuid.string_random ());
        operation_manager.create_note.begin (new_note);
    }

    private void create_new_folder (Variant? param) requires (param != null) {
        var parent_uri = get_parent_uri_for_creation ();

        var maybe = param.get_maybe ();
        if (maybe != null) {
            parent_uri = maybe.get_string ();
        }

        var parent_file = File.new_for_uri (parent_uri);
        var new_dir = parent_file.get_child (Uuid.string_random ());
        operation_manager.create_directory.begin (new_dir);
    }

    private string get_parent_uri_for_creation () {
        if (selection_model.get_selection ().is_empty ()) {
            return ((Notebook) notebook_selection.selected_item).uri;
        }

        // TODO: Support multi selection
        var first_selected_index = selection_model.get_selection ().get_nth (0);
        var first_selected_row = (Gtk.TreeListRow) selection_model.get_item (first_selected_index);

        var first_selected = (FileBase) first_selected_row.item;

        if (first_selected is Directory) {
            return first_selected.uri;
        }

        return first_selected.file.get_parent ().get_uri ();
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
    private Gtk.TreeListModel? create_tree_model (Notebook? notebook) {
        if (notebook == null || notebook.root == null) {
            return null;
        }

        return new Gtk.TreeListModel (notebook.root.children, false, false, create_child_model_func);
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
    private void on_activate (Gtk.ListView list_view, uint position) {
        var row = (Gtk.TreeListRow) list_view.model.get_item (position);
        var note = (Note) row.item;
        activate_action_variant (MainWindow.ACTION_PREFIX + MainWindow.OPEN_NOTE_ACTION, new Variant.string (note.uri));
    }
}
