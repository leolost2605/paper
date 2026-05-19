/*
* SPDX-License-Identifier: GPL-3.0-or-later
* SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
*/

public abstract class Quicknote.Exporter : Object {
    public async abstract void export (File file) throws Error;
}
