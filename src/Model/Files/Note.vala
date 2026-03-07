/*
 * SPDX-License-Identifier: GPL-3.0-or-later
 * SPDX-FileCopyrightText: 2026 Leonhard Kargl <leo.kargl@proton.me>
 */

public class Quicknote.Note : FileBase {
    public Content content { get; private set; }

    private Database database;
    private uint opened = 0;

    public Note (File file, FileInfo info) {
        Object (file: file, info: info);
    }

    construct {
        database = new Database (file.get_path ());
        content = new Content (database);
    }

    public async void open () throws Error {
        opened++;

        if (opened == 1) {
            yield database.open ();
        }
    }

    public void close () requires (opened > 0) {
        opened--;

        if (opened == 0) {
            database.close ();
        }
    }
}
