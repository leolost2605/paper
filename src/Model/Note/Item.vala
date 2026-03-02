/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public abstract class Quicknote.Item : Object {
    public abstract void snapshot (Gtk.Snapshot snapshot);
    public abstract Graphene.Rect get_bounds ();
    public abstract bool intersects (Line line);
}
