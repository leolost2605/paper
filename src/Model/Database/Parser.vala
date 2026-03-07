/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.Parser : Object {
    public void parse_note (Note note, Json.Object json) throws Error {
        var background = json.get_object_member ("background");

        parse_background (note, background);

        var items = json.get_array_member ("items");

        for (uint i = 0; i < items.get_length (); i++) {
            var item = items.get_object_element (i);

            parse_item (note, item);
        }
    }

    private void parse_background (Note note, Json.Object json) throws Error {
        var type = json.get_string_member ("type");

        if (type == "white") {
            note.background = new WhiteBackground ();
        } else {
            throw new IOError.FAILED ("Unknown background type: %s".printf (type));
        }
    }

    private void parse_item (Note note, Json.Object json) throws Error {
        var type = json.get_string_member ("type");
        var data = json.get_object_member ("data");

        if (type == "stroke") {
            parse_stroke (note, data);
        } else {
            throw new IOError.FAILED ("Unknown item type: %s".printf (type));
        }
    }

    private void parse_stroke (Note note, Json.Object json) throws Error {
        var points_array = json.get_array_member ("points");
        var points = new Point[points_array.get_length ()];

        for (uint i = 0; i < points_array.get_length (); i++) {
            var point_json = points_array.get_object_element (i);

            var x = (float) point_json.get_double_member ("x");
            var y = (float) point_json.get_double_member ("y");

            points[i] = new Point (x, y);
        }

        var width = (float) json.get_double_member ("width");

        var color_json = json.get_object_member ("color");

        var r = (float) color_json.get_double_member ("r");
        var g = (float) color_json.get_double_member ("g");
        var b = (float) color_json.get_double_member ("b");
        var a = (float) color_json.get_double_member ("a");

        var color = Gdk.RGBA () {
            red = r,
            green = g,
            blue = b,
            alpha = a,
        };

        note.items.add (new Stroke (new Line (points), width, color));
    }

    public Json.Node build_note (Note note) throws Error {
        var builder = new Json.Builder ();

        builder.begin_object ();

        builder.set_member_name ("background");
        build_background (builder, note.background);

        builder.set_member_name ("items");
        builder.begin_array ();

        foreach (var item in note.items.get_all ()) {
            build_item (builder, item);
        }

        builder.end_array ();

        builder.end_object ();

        return builder.get_root ();
    }

    private void build_background (Json.Builder builder, Background background) throws Error {
        if (background is WhiteBackground) {
            builder.begin_object ();
            builder.set_member_name ("type");
            builder.add_string_value ("white");
            builder.end_object ();
        } else {
            throw new IOError.FAILED ("Unknown background type: %s".printf (background.get_type ().name ()));
        }
    }

    private void build_item (Json.Builder builder, Item item) throws Error {
        if (item is Stroke) {
            builder.begin_object ();
            builder.set_member_name ("type");
            builder.add_string_value ("stroke");
            builder.set_member_name ("data");
            build_stroke (builder, (Stroke) item);
            builder.end_object ();
        } else {
            throw new IOError.FAILED ("Unknown item type: %s".printf (item.get_type ().name ()));
        }
    }

    private void build_stroke (Json.Builder builder, Stroke stroke) {
        builder.begin_object ();

        builder.set_member_name ("points");
        builder.begin_array ();

        foreach (var point in stroke.line.get_points ()) {
            builder.begin_object ();
            builder.set_member_name ("x");
            builder.add_double_value (point.x);
            builder.set_member_name ("y");
            builder.add_double_value (point.y);
            builder.end_object ();
        }

        builder.end_array ();

        builder.set_member_name ("width");
        builder.add_double_value (stroke.width);

        builder.set_member_name ("color");
        builder.begin_object ();
        builder.set_member_name ("r");
        builder.add_double_value (stroke.color.red);
        builder.set_member_name ("g");
        builder.add_double_value (stroke.color.green);
        builder.set_member_name ("b");
        builder.add_double_value (stroke.color.blue);
        builder.set_member_name ("a");
        builder.add_double_value (stroke.color.alpha);
        builder.end_object ();

        builder.end_object ();
    }
}
