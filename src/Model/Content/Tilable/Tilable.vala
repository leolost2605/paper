/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

/**
 * Tilables are the things that make up the background of the document. This can
 * be the actual background but also a pattern, etc.
 */
public abstract class Paper.Tilable : Object {
    public abstract Graphene.Size get_tile_size ();
    public abstract void snapshot_tile (Gtk.Snapshot snapshot);
}
