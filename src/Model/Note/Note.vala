/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.Note : Object {
    public Background background { get; construct set; }
    public ItemStore items { get; construct; }

    construct {
        background = new WhiteBackground ();
        items = new ItemStore ();
    }
}
