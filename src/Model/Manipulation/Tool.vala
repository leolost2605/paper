/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public abstract class Quicknote.Tool : Object {
    public abstract void start (Note note);
    public abstract void add_point (float x, float y);
    public abstract void commit ();
}
