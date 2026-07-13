/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Paper.ItemRenderer : Object {
    public Gsk.RenderNode render_item (Item item) {
        var bounds = item.get_bounds ();
        var surface = new Cairo.ImageSurface (ARGB32, (int) bounds.size.width, (int) bounds.size.height);
        var ctx = new Cairo.Context (surface);

        var snapshot = new Gtk.Snapshot ();
        snapshot.transform (new Gsk.Transform ().translate (bounds.origin).invert ());
        item.snapshot (snapshot);

        var node = snapshot.free_to_node ();
        node.draw (ctx);

        surface.flush ();

        unowned var data = surface.get_data ();

        var bytes = Bytes.new_with_owner<Cairo.ImageSurface> (data, surface);

        var mem_texture = new Gdk.MemoryTexture (surface.get_width (), surface.get_height (), B8G8R8A8, bytes, surface.get_stride ());

        var texture_node = new Gsk.TextureNode (mem_texture, bounds);
        warning ("Created texture node");
        return texture_node;
    }
}
