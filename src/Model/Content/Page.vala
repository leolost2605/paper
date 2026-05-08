/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public class Quicknote.Page : Object {
    public Graphene.Rect bounds { get; construct; }

    public Page (Graphene.Rect bounds) {
        Object (bounds: bounds);
    }
}
