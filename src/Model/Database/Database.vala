/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */


public class Quicknote.Database : Object {
    private const string SETUP_QUERY = """
        CREATE TABLE IF NOT EXISTS note (
            id INTEGER PRIMARY KEY,
            background_type TEXT
        );

        CREATE TABLE IF NOT EXISTS note_item (
            id INTEGER PRIMARY KEY,
            type TEXT,
            type_id INTEGER
        );

        CREATE TABLE IF NOT EXISTS strokes (
            id INTEGER PRIMARY KEY,
            coords TEXT,
            r REAL,
            g REAL,
            b REAL,
            a REAL,
            width REAL
        );

        CREATE VIRTUAL TABLE IF NOT EXISTS item_bounds USING rtree(
            item_id,
            min_x, max_x,
            min_y, max_y
        );
    """;

    private const string BACKGROUND_QUERY = "SELECT background_type FROM note WHERE id = 0";

    private const string BOUNDS_QUERY = """
        SELECT item_id FROM item_bounds
        WHERE NOT (min_x > ? OR max_x < ? OR min_y > ? OR max_y < ?)
    """;

    private const string GET_ITEM_QUERY = "SELECT type, type_id FROM note_item WHERE id = ?";

    private const string GET_STROKE_QUERY = "SELECT coords, r, g, b, a, width FROM strokes WHERE id = ?";

    private const string REMOVE_ITEM_QUERY = "DELETE FROM note_item WHERE id = ?";

    private const string REMOVE_ITEM_FROM_TREE_QUERY = "DELETE FROM item_bounds WHERE item_id = ?";

    private const string ADD_ITEM_QUERY = "INSERT INTO note_item (type, type_id) VALUES (?, ?)";

    private const string ADD_TO_TREE_QUERY = """
        INSERT INTO item_bounds (item_id, min_x, max_x, min_y, max_y)
        VALUES (?, ?, ?, ?, ?)
    """;

    private const string ADD_STROKE_QUERY = "INSERT INTO strokes (coords, r, g, b, a, width) VALUES (?, ?, ?, ?, ?, ?)";

    public string path { get; construct; }

    private Sqlite.Database? db;

    public Database (string path) {
        Object (path: path);
    }

    public async void open () throws Error {
        if (db != null) {
            return;
        }

        var ec = Sqlite.Database.open (path, out db);

        if (ec != Sqlite.OK) {
            throw new IOError.FAILED ("Failed to open database: %s".printf (db.errmsg ()));
        }

        ec = db.exec (SETUP_QUERY);
        if (ec != Sqlite.OK) {
            throw new IOError.FAILED ("Failed to setup database: %s".printf (db.errmsg ()));
        }
    }

    public Background get_background () throws Error {
        Sqlite.Statement stmt;
        var ec = db.prepare_v2 (BACKGROUND_QUERY, BACKGROUND_QUERY.length, out stmt);

        if (ec != Sqlite.OK) {
            throw new IOError.FAILED ("Failed to prepare statement: %s".printf (db.errmsg ()));
        }

        if (stmt.step () == Sqlite.ROW) {
            var type = stmt.column_text (0);
            warning (type);
        }

        throw new IOError.FAILED ("Failed to get background type: %s".printf (db.errmsg ()));
    }

    public Gee.ArrayList<int> get_items_intersecting (Graphene.Rect bounds) throws Error {
        Sqlite.Statement stmt;
        var ec = db.prepare_v2 (BOUNDS_QUERY, BOUNDS_QUERY.length, out stmt);

        if (ec != Sqlite.OK) {
            throw new IOError.FAILED ("Failed to prepare statement: %s".printf (db.errmsg ()));
        }

        stmt.bind_double (1, bounds.origin.x + bounds.size.width);
        stmt.bind_double (2, bounds.origin.x);
        stmt.bind_double (3, bounds.origin.y + bounds.size.height);
        stmt.bind_double (4, bounds.origin.y);

        var result = new Gee.ArrayList<int> ();

        while (stmt.step () == Sqlite.ROW) {
            result.add (stmt.column_int (0));
        }

        return result;
    }

    public Item get_item (int id) throws Error {
        Sqlite.Statement stmt;
        var ec = db.prepare_v2 (GET_ITEM_QUERY, GET_ITEM_QUERY.length, out stmt);

        if (ec != Sqlite.OK) {
            throw new IOError.FAILED ("Failed to prepare statement: %s".printf (db.errmsg ()));
        }

        stmt.bind_int (1, id);

        if (stmt.step () != Sqlite.ROW) {
            throw new IOError.FAILED ("Failed to get item with id %d: %s".printf (id, db.errmsg ()));
        }

        var type = stmt.column_text (0);
        var type_id = stmt.column_int (1);

        switch (type) {
            case "stroke":
                return get_stroke (type_id);
            default:
                throw new IOError.FAILED ("Unknown item type '%s' for item with id %d".printf (type, id));
        }
    }

    private Stroke get_stroke (int id) throws Error {
        Sqlite.Statement stmt;
        var ec = db.prepare_v2 (GET_STROKE_QUERY, GET_STROKE_QUERY.length, out stmt);

        if (ec != Sqlite.OK) {
            throw new IOError.FAILED ("Failed to prepare statement: %s".printf (db.errmsg ()));
        }

        stmt.bind_int (1, id);

        if (stmt.step () != Sqlite.ROW) {
            throw new IOError.FAILED ("Failed to get stroke with id %d: %s".printf (id, db.errmsg ()));
        }

        var coords_str = stmt.column_text (0);
        var coords_array = coords_str.split (";");
        var points = new Point[coords_array.length / 2];

        for (int i = 0; i < coords_array.length; i += 2) {
            var x = float.parse (coords_array[i]);
            var y = float.parse (coords_array[i + 1]);
            points[i / 2] = new Point (x, y);
        }

        var line = new Line (points);
        var width = (float) stmt.column_double (5);
        var color = Gdk.RGBA () {
            red = (float) stmt.column_double (1),
            green = (float) stmt.column_double (2),
            blue = (float) stmt.column_double (3),
            alpha = (float) stmt.column_double (4),
        };

        return new Stroke (line, width, color);
    }

    public void remove_item (int id) throws Error {
        Sqlite.Statement stmt;
        var ec = db.prepare_v2 (REMOVE_ITEM_QUERY, REMOVE_ITEM_QUERY.length, out stmt);

        if (ec != Sqlite.OK) {
            throw new IOError.FAILED ("Failed to prepare statement: %s".printf (db.errmsg ()));
        }

        stmt.bind_int (1, id);

        if (stmt.step () != Sqlite.DONE) {
            throw new IOError.FAILED ("Failed to remove item with id %d: %s".printf (id, db.errmsg ()));
        }

        ec = db.prepare_v2 (REMOVE_ITEM_FROM_TREE_QUERY, REMOVE_ITEM_FROM_TREE_QUERY.length, out stmt);

        if (ec != Sqlite.OK) {
            throw new IOError.FAILED ("Failed to prepare statement: %s".printf (db.errmsg ()));
        }

        stmt.bind_int (1, id);

        if (stmt.step () != Sqlite.DONE) {
            throw new IOError.FAILED ("Failed to remove item from tree with id %d: %s".printf (id, db.errmsg ()));
        }
    }

    public void add_item (Item item) throws Error {
        string type;
        int64 type_id;

        if (item is Stroke) {
            type = "stroke";
            type_id = add_stroke ((Stroke) item);
        } else {
            throw new IOError.FAILED ("Unknown item type '%s'".printf (item.get_type ().name ()));
        }

        Sqlite.Statement stmt;
        var ec = db.prepare_v2 (ADD_ITEM_QUERY, ADD_ITEM_QUERY.length, out stmt);

        if (ec != Sqlite.OK) {
            throw new IOError.FAILED ("Failed to prepare statement: %s".printf (db.errmsg ()));
        }

        stmt.bind_text (1, type);
        stmt.bind_int64 (2, type_id);

        if (stmt.step () != Sqlite.DONE) {
            throw new IOError.FAILED ("Failed to add stroke: %s".printf (db.errmsg ()));
        }

        var id = db.last_insert_rowid ();
        add_to_tree (id, item.get_bounds ());
    }

    private void add_to_tree (int64 item_id, Graphene.Rect bounds) throws Error {
        Sqlite.Statement stmt;
        var ec = db.prepare_v2 (ADD_TO_TREE_QUERY, ADD_TO_TREE_QUERY.length, out stmt);

        if (ec != Sqlite.OK) {
            throw new IOError.FAILED ("Failed to prepare statement: %s".printf (db.errmsg ()));
        }

        stmt.bind_int64 (1, item_id);
        stmt.bind_double (2, bounds.origin.x);
        stmt.bind_double (3, bounds.origin.x + bounds.size.width);
        stmt.bind_double (4, bounds.origin.y);
        stmt.bind_double (5, bounds.origin.y + bounds.size.height);

        if (stmt.step () != Sqlite.DONE) {
            throw new IOError.FAILED ("Failed to add item to tree: %s".printf (db.errmsg ()));
        }
    }

    private int64 add_stroke (Stroke stroke) throws Error {
        var coords_str = "";

        foreach (var point in stroke.line.get_points ()) {
            coords_str += "%f;%f;".printf (point.x, point.y);
        }

        Sqlite.Statement stmt;
        var ec = db.prepare_v2 (ADD_STROKE_QUERY, ADD_STROKE_QUERY.length, out stmt);

        if (ec != Sqlite.OK) {
            throw new IOError.FAILED ("Failed to prepare statement: %s".printf (db.errmsg ()));
        }

        stmt.bind_text (1, coords_str);
        stmt.bind_double (2, stroke.color.red);
        stmt.bind_double (3, stroke.color.green);
        stmt.bind_double (4, stroke.color.blue);
        stmt.bind_double (5, stroke.color.alpha);
        stmt.bind_double (6, stroke.width);

        if (stmt.step () != Sqlite.DONE) {
            throw new IOError.FAILED ("Failed to add stroke: %s".printf (db.errmsg ()));
        }

        return db.last_insert_rowid ();
    }
}
