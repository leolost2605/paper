/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Paper.ItemRenderer : Object {
    public Gsk.RenderNode render_item (Item item, float scale) {
        var bounds = item.get_bounds ();
        var scaled_width = (int) Math.ceilf (bounds.size.width * scale);
        var scaled_height = (int) Math.ceilf (bounds.size.height * scale);

        var surface = new Cairo.ImageSurface (ARGB32, scaled_width, scaled_height);
        var ctx = new Cairo.Context (surface);

        var snapshot = new Gtk.Snapshot ();
        snapshot.translate ({ -bounds.origin.x * scale, -bounds.origin.y * scale });
        snapshot.scale (scale, scale);

        item.snapshot (snapshot);

        var node = snapshot.free_to_node ();
        node.draw (ctx);

        surface.flush ();

        unowned var data = surface.get_data ();

        var bytes = Bytes.new_with_owner<Cairo.ImageSurface> (data, surface);

        var mem_texture = new Gdk.MemoryTexture (surface.get_width (), surface.get_height (), B8G8R8A8, bytes, surface.get_stride ());

        var texture_node = new Gsk.TextureNode (mem_texture, bounds);

        return texture_node;
    }
}
