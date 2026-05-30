/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.NotesList : Adw.NavigationPage {
    private const string ACTION_GROUP_NAME = "notes_list";
    public const string ACTION_PREFIX = "notes_list.";
    private const string CREATE_NOTE_ACTION = "create_note";
    private const string CREATE_FOLDER_ACTION = "create_folder";
    public const string DELETE_ACTION = "delete";
    public const string RENAME_ACTION = "rename";

    public Notebook notebook { get; construct; }

    public FileBase? selected_file { get { return (FileBase?) ((Gtk.TreeListRow?) selection_model.selected_item)?.item; } }

    private Gtk.SingleSelection selection_model;
    private OperationManager operation_manager;

    public NotesList (Notebook notebook) {
        Object (notebook: notebook);
    }

    construct {
        var sorted_children = create_sort_model (notebook.root.children);
        var tree_model = new Gtk.TreeListModel (sorted_children, false, false, create_child_model_func);

        selection_model = new Gtk.SingleSelection (tree_model) {
            autoselect = true
        };
        selection_model.selection_changed.connect (on_selection_changed);

        var factory = new Gtk.SignalListItemFactory ();
        factory.setup.connect (on_setup);
        factory.bind.connect (on_bind);
        factory.unbind.connect (on_unbind);

        var list_view = new Gtk.ListView (selection_model, factory);
        list_view.add_css_class ("navigation-sidebar");

        var scrolled_window = new Gtk.ScrolledWindow () {
            child = list_view,
            hscrollbar_policy = NEVER,
        };

        var create_note_button = new Gtk.Button.from_icon_name ("document-new") {
            action_name = ACTION_PREFIX + CREATE_NOTE_ACTION,
            action_target = new Variant.maybe (VariantType.STRING, null)
        };
        create_note_button.add_css_class (Granite.STYLE_CLASS_LARGE_ICONS);

        var create_folder_button = new Gtk.Button.from_icon_name ("folder-new") {
            action_name = ACTION_PREFIX + CREATE_FOLDER_ACTION,
            action_target = new Variant.maybe (VariantType.STRING, null)
        };
        create_folder_button.add_css_class (Granite.STYLE_CLASS_LARGE_ICONS);

        var main_menu = new Menu ();

        var menu_button = new Gtk.MenuButton () {
            icon_name = "open-menu",
            menu_model = main_menu
        };
        menu_button.add_css_class (Granite.STYLE_CLASS_LARGE_ICONS);

        var header_bar = new Adw.HeaderBar () {
            show_title = false
        };
        header_bar.pack_start (create_note_button);
        header_bar.pack_start (create_folder_button);
        header_bar.pack_end (menu_button);

        var toolbar_view = new Adw.ToolbarView () {
            content = scrolled_window,
        };
        toolbar_view.add_top_bar (header_bar);

        child = toolbar_view;
        title = _("Notes");

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

    private void on_selection_changed () {
        notify_property ("selected-file");
    }

    private ListModel? create_child_model_func (Object item) {
        if (!(item is Directory)) {
            return null;
        }

        return create_sort_model (((Directory) item).children);
    }

    private static Gtk.SortListModel create_sort_model (ListModel model) {
        var folder_before_files_sorter = new Gtk.CustomSorter (folder_before_files_sort_func);

        var name_expression = new Gtk.PropertyExpression (typeof (FileBase), null, "display-name");
        var name_sorter = new Gtk.StringSorter (name_expression);

        var multi_sorter = new Gtk.MultiSorter ();
        multi_sorter.append (folder_before_files_sorter);
        multi_sorter.append (name_sorter);

        return new Gtk.SortListModel (model, multi_sorter);
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

    private void on_setup (Object obj) {
        var item = (Gtk.ListItem) obj;
        item.child = new NotesListItem (selection_model);
    }

    private void on_bind (Object obj) {
        var item = (Gtk.ListItem) obj;
        var tree_row = (Gtk.TreeListRow) item.item;

        var file = (FileBase) tree_row.item;
        file.load ();

        if (file is Directory) {
            file.bind_property ("expanded", tree_row, "expanded", SYNC_CREATE | BIDIRECTIONAL);
        }

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
