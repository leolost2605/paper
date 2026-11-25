/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

[GtkTemplate (ui = "/io/github/leolost2605/paper/ui/note-list-item.ui")]
public class Paper.NoteListItem : Granite.Bin {
    public Object item { get; set; }
}
