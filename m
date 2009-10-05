From: Petr Rockai <prockai@redhat.com>
Date: Mon, 05 Oct 2009 23:43:03 +0200
Subject: [PATCH] [DRAFT] Binary backups (aka pvcreate --undo, RHBZ#174701)
Message-ID: <871vlhcyag.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I'm attaching a first draft of the binary backup stuff. There's a lot of code,
roughly in 4 areas:
- export lower levels of the config parsing and writing library code
- code for reading and writing the backup format using the above
- hook into dev_write and dev_set to back up before overwriting
- code for restoring the backups

The format currently looks like this:

offset=123
old="..."
new="..."
<repeat>

where old and new are base64-encoded chunks of data, at most 512-byte each
(something less than 700 bytes in base64).

I'd probably prepend a "version=X" to the start, and maybe a bit of metadata --
the files are stored as pv-<uuid>.bin and lv-<uuid>.bin, but don't themselves
contain any hint as to what they are.

The backup part of the code should be straightforward. The restore is, on the
other hand, quite laborious, as a lot of checking is done on the backup file --
we will refuse to restore a backup if the device has changed since that backup
had been made, to avoid data loss (we may want to add -f to override that
check). There's some extra complexity to deal with the fact that a single
command may overwrite same sector multiple times. I think the current design is
fairly robust in that respect -- more so than a more intelligent (and more
error-prone) implementation squashing the backed-up sectors at backup time
would be.

The current implementation is not 100% efficient (especially on the memory side
of things), but can be improved if this turns out to be a problem.

The code is not completely done/ready, but a preliminary review would be
definitely appreciated. It does come with a test that passes and I think it's
in a fairly good shape correctness-wise, but there are some cleanups that ought
to be done before merging.

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: binbackup.diff
Type: text/x-diff
Size: 49737 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20091005/a9c4134d/attachment.bin>
