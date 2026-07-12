/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public abstract class Paper.Background : Object {
    public abstract void snapshot (Gtk.Snapshot snapshot, Graphene.Rect bounds);
}
