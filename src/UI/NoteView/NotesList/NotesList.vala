/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

[GtkTemplate (ui = "/io/github/leolost2605/paper/ui/note-list.ui")]
public class Paper.NotesList : Adw.NavigationPage {
    private const string ACTION_GROUP_NAME = "notes_list";
    public const string ACTION_PREFIX = "notes_list.";
    private const string CREATE_NOTE_ACTION = "create_note";
    private const string CREATE_FOLDER_ACTION = "create_folder";
    public const string DELETE_ACTION = "delete";
    public const string RENAME_ACTION = "rename";

    public Notebook notebook { get; construct; }

    public FileBase? selected_file {
        get { return (FileBase?) ((Gtk.TreeListRow?) selection_model.selected_item)?.item; }
        set {
            for (uint i = 0; i < selection_model.n_items; i++) {
                var row = (Gtk.TreeListRow) selection_model.get_item (i);

                if ((FileBase) row.item == value) {
                    selection_model.selected = i;
                    return;
                }
            }

            selection_model.unselect_all ();
        }
    }

    [GtkChild]
    private unowned Gtk.SingleSelection selection_model;
    private OperationManager operation_manager;

    public NotesList (Notebook notebook) {
        Object (notebook: notebook);
    }

    construct {
        operation_manager = new OperationManager (selection_model);

        var create_note_action = new SimpleAction (CREATE_NOTE_ACTION, new VariantType.maybe (VariantType.STRING));
        create_note_action.activate.connect (create_new_note);
        var create_folder_action = new SimpleAction (CREATE_FOLDER_ACTION, new VariantType.maybe (VariantType.STRING));
        create_folder_action.activate.connect (create_new_folder);
        var delete_action = new SimpleAction (DELETE_ACTION, null);
        delete_action.activate.connect (delete_note);
        var rename_action = new SimpleAction (RENAME_ACTION, null);
        rename_action.activate.connect (rename_file);

        var action_group = new SimpleActionGroup ();
        action_group.add_action (create_note_action);
        action_group.add_action (create_folder_action);
        action_group.add_action (delete_action);
        action_group.add_action (rename_action);
        insert_action_group (ACTION_GROUP_NAME, action_group);
    }

    [GtkCallback]
    private void on_selection_changed () {
        notify_property ("selected-file");
    }

    [GtkCallback]
    private Gtk.TreeListModel? create_tree_model (Notebook? notebook) {
        if (notebook == null || notebook.root == null) {
            return null;
        }

        var tree_model = new Gtk.TreeListModel (notebook.root.children, false, false, create_child_model_func);
        return tree_model;
    }

    private ListModel? create_child_model_func (Object item) {
        if (!(item is Directory)) {
            return null;
        }

        var directory = (Directory) item;
        directory.load ();

        return directory.children;
    }

    private static int folder_before_files_sort_func (Object? a, Object? b) {
        var file_a = (FileBase) a;
        var file_b = (FileBase) b;

        if (file_a is Directory && !(file_b is Directory)) {
            return -1;
        } else if (!(file_a is Directory) && file_b is Directory) {
            return 1;
        } else {
            return 0;
        }
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
        if (selected_file == null) {
            return notebook.root.uri;
        }

        if (selected_file is Directory) {
            return selected_file.uri;
        }

        return selected_file.file.get_parent ().get_uri ();
    }

    private void delete_note (Variant? param) requires (param == null) {
        if (selected_file == null) {
            return;
        }

        var message_dialog = new Granite.MessageDialog (
            _("Delete “%s”?").printf (selected_file.display_name),
            _("This can't be undone"),
            new ThemedIcon ("edit-delete"),
            NONE
        ) {
            transient_for = (Gtk.Window) get_root (),
            modal = true,
        };
        message_dialog.set_data ("file", selected_file.file);
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
        if (selected_file == null) {
            return;
        }

        new RenameDialog (selected_file, operation_manager) {
            transient_for = get_root () as Gtk.Window,
            modal = true,
        }.present ();
    }
}
