/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.NotesList : Adw.NavigationPage {
    private const string ACTION_GROUP_NAME = "notes_list";
    private const string ACTION_PREFIX = ACTION_GROUP_NAME + ".";
    private const string CREATE_NOTE_ACTION = "create_note";
    private const string CREATE_FOLDER_ACTION = "create_folder";

    public Notebook notebook { get; construct; }

    public Note? selected_note { get; set; }

    private OperationManager operation_manager;

    public NotesList (Notebook notebook) {
        Object (notebook: notebook);
    }

    construct {
        var tree_model = new Gtk.TreeListModel (notebook.root.children, false, false, create_child_model_func);

        var selection_model = new Gtk.SingleSelection (tree_model) {
            autoselect = true
        };
        bind_property (
            "selected-note", selection_model, "selected", SYNC_CREATE | BIDIRECTIONAL,
            (binding, from_val, ref to_val) => {
                var note = (Note?) from_val.get_object ();

                if (note == null) {
                    to_val.set_uint (Gtk.INVALID_LIST_POSITION);
                    return true;
                }

                for (uint i = 0; i < tree_model.n_items; i++) {
                    var row = (Gtk.TreeListRow) tree_model.get_item (i);

                    if (row.item == note) {
                        to_val.set_uint (i);
                        return true;
                    }
                }

                return false;
            }, (binding, from_val, ref to_val) => {
                var index = from_val.get_uint ();

                if (index == Gtk.INVALID_LIST_POSITION) {
                    to_val.set_object (null);
                    return true;
                }

                var row = (Gtk.TreeListRow) tree_model.get_item (index);

                if (row.item is Note) {
                    to_val.set_object ((Note) row.item);
                    return true;
                }

                return false;
            }
        );

        var factory = new Gtk.SignalListItemFactory ();
        factory.setup.connect (on_setup);
        factory.bind.connect (on_bind);
        factory.unbind.connect (on_unbind);

        var list_view = new Gtk.ListView (selection_model, factory);
        list_view.add_css_class ("notes-list");

        var scrolled_window = new Gtk.ScrolledWindow () {
            child = list_view,
            hscrollbar_policy = NEVER,
        };

        var create_note_button = new Gtk.Button.from_icon_name ("document-new") {
            action_name = ACTION_PREFIX + CREATE_NOTE_ACTION,
            action_target = new Variant.maybe (VariantType.STRING, null)
        };

        var create_folder_button = new Gtk.Button.from_icon_name ("folder-new") {
            action_name = ACTION_PREFIX + CREATE_FOLDER_ACTION,
            action_target = new Variant.maybe (VariantType.STRING, null)
        };

        var toolbar = new Granite.Box (HORIZONTAL) {
            margin_start = 3,
            margin_bottom = 3,
            margin_end = 3,
            margin_top = 3,
        };
        toolbar.append (create_note_button);
        toolbar.append (create_folder_button);

        var toolbar_view = new Adw.ToolbarView () {
            content = scrolled_window,
        };
        toolbar_view.add_bottom_bar (toolbar);

        child = toolbar_view;
        title = _("Notes");

        operation_manager = new OperationManager (selection_model);

        var create_note_action = new SimpleAction (CREATE_NOTE_ACTION, new VariantType.maybe (VariantType.STRING));
        create_note_action.activate.connect (create_new_note);
        var create_folder_action = new SimpleAction (CREATE_FOLDER_ACTION, new VariantType.maybe (VariantType.STRING));
        create_folder_action.activate.connect (create_new_folder);

        var action_group = new SimpleActionGroup ();
        action_group.add_action (create_note_action);
        action_group.add_action (create_folder_action);
        insert_action_group (ACTION_GROUP_NAME, action_group);
    }

    private ListModel? create_child_model_func (Object item) {
        return (item as Directory)?.children;
    }

    private void on_setup (Object obj) {
        var item = (Gtk.ListItem) obj;
        item.child = new NotesListItem ();
    }

    private void on_bind (Object obj) {
        var item = (Gtk.ListItem) obj;
        var tree_row = (Gtk.TreeListRow) item.item;

        var file = (FileBase) tree_row.item;
        file.load ();

        var notes_list_item = (NotesListItem) item.child;
        notes_list_item.row = tree_row;
    }

    private void on_unbind (Object obj) {
        var item = (Gtk.ListItem) obj;
        var tree_row = (Gtk.TreeListRow) item.item;

        var file = (FileBase) tree_row.item;
        file.queue_unload ();

        var notes_list_item = (NotesListItem) item.child;
        notes_list_item.row = null;
    }

    private void create_new_note (Variant? param) requires (param != null) {
        var parent_uri = (selected_note is Directory) ? selected_note.uri : selected_note.file.get_parent ().get_uri ();

        var maybe = param.get_maybe ();
        if (maybe != null) {
            parent_uri = maybe.get_string ();
        }

        var parent_file = File.new_for_uri (parent_uri);
        var new_note = parent_file.get_child (Uuid.string_random ());
        operation_manager.create_note.begin (new_note);
    }

    private void create_new_folder (Variant? param) requires (param != null) {
        var parent_uri = (selected_note is Directory) ? selected_note.uri : selected_note.file.get_parent ().get_uri ();

        var maybe = param.get_maybe ();
        if (maybe != null) {
            parent_uri = maybe.get_string ();
        }

        var parent_file = File.new_for_uri (parent_uri);
        var new_dir = parent_file.get_child (Uuid.string_random ());
        operation_manager.create_directory.begin (new_dir);
    }
}
