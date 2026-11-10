/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Paper.ItemRenderer : Object {
    public Gsk.RenderNode render_item (Item item, float scale) {
        var bounds = item.get_bounds ();

        var snapshot = new Gtk.Snapshot ();
        snapshot.translate ({ -bounds.origin.x * scale, -bounds.origin.y * scale });
        snapshot.scale (scale, scale);

        item.snapshot (snapshot);

        var node = snapshot.free_to_node ();

        var source_bounds = Graphene.Rect () {
            origin = { 0, 0 },
            size = { bounds.size.width * scale, bounds.size.height * scale }
        };

        return render_to_texture (node, source_bounds, bounds);
    }

    public Gsk.RenderNode render_tilable (Tilable tilable, float scale) {
        var tile_size = tilable.get_tile_size ();

        var snapshot = new Gtk.Snapshot ();
        snapshot.scale (scale, scale);

        tilable.snapshot_tile (snapshot);

        var node = snapshot.free_to_node ();

        var source_bounds = Graphene.Rect () {
            origin = { 0, 0 },
            size = { tile_size.width * scale, tile_size.height * scale }
        };

        var target_bounds = Graphene.Rect () {
            origin = { 0, 0 },
            size = tile_size
        };

        return render_to_texture (node, source_bounds, target_bounds);
    }

    public Gsk.RenderNode render_to_texture (Gsk.RenderNode node, Graphene.Rect source_bounds, Graphene.Rect target_bounds) {
        var texture_width = (int) Math.ceilf (source_bounds.size.width);
        var texture_height = (int) Math.ceilf (source_bounds.size.height);

        var surface = new Cairo.ImageSurface (ARGB32, texture_width, texture_height);
        var ctx = new Cairo.Context (surface);
        ctx.translate (source_bounds.origin.x, source_bounds.origin.y);

        node.draw (ctx);

        surface.flush ();

        unowned var data = surface.get_data ();

        var bytes = Bytes.new_with_owner<Cairo.ImageSurface> (data, surface);

        var mem_texture = new Gdk.MemoryTexture (surface.get_width (), surface.get_height (), B8G8R8A8, bytes, surface.get_stride ());

        var texture_node = new Gsk.TextureNode (mem_texture, target_bounds);

        return texture_node;
    }
}
