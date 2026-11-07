/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Paper.PdfPage : Item {
    public File file { get; construct; }
    public int page_index { get; construct; }
    public Graphene.Point position { get; construct; }

    private Poppler.Page page;

    private Graphene.Rect bounds;

    public PdfPage (File file, int page_index, Graphene.Point position) {
        Object (file: file, page_index: page_index, position: position);
    }

    construct {
        try {
            var document = new Poppler.Document.from_gfile (file, null, null);
            page = document.get_page (page_index);
        } catch (Error e) {
            warning ("Failed to open document %s: %s", file.get_path (), e.message);
            return;
        }

        double width, height;
        page.get_size (out width, out height);
        bounds = Graphene.Rect () {
            origin = position,
            size = { (float) width, (float) height }
        };
    }

    public override void snapshot (Gtk.Snapshot snapshot) {
        var node = new Gsk.CairoNode (bounds);
        var context = node.get_draw_context ();
        context.translate (position.x, position.y);
        page.render (context);

        snapshot.append_node (node);
    }

    public override void snapshot_selected (Gtk.Snapshot snapshot) {
        this.snapshot (snapshot);
    }

    public override Graphene.Rect get_bounds () {
        return bounds;
    }

    public override bool is_near (Graphene.Point point, float epsilon) {
        return bounds.contains_point (point);
    }

    public override Item copy_transformed (Gsk.Transform transform) {
        return new PdfPage (file, page_index, transform.transform_point (position));
    }
}
