From: Marian Csontos <mcsontos@redhat.com>
Date: Tue, 23 Nov 2021 16:58:20 +0100
Subject: atime/mtime for VG/PV
Message-ID: <CAJNi=XryUgjw3BuiMZV4CX6GSUD7sfLyaa2a-_gpj9f_iH+Yug@mail.gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi folks, as various issues with duplicates are being solved, I wondered if
it would be beneficial to include things like atime/mtime in metadata.

Actually mtime is already there in the VG metadata: seqno + timestamp.

So what would atime be?
Store a timestamp on activation of an LV in the VG? Write on any lvm
operation? Or write timestamp more frequently when there are active devices?

atime should be stored in PV metadata, even if there is no VG MDA - these
would benefit the most as there is no VG MDA and thus no "mtime".

When there are duplicates higher atime would be almost certainly the
correct device, unless user intends to use a LUN's snapshot, but that would
require an input from user anyway.

User MUST be able to turn it of ("noatime") in case of being slow for
hundreds/thousands of PVs.

Perhaps this would not have to be fsynced all the time, but then there may
be a chance for mismatch and for snapshot having higher timestamp than
original PV.

-- Martian
-------------- next part --------------
An HTML attachment was scrubbed...
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20211123/f8fd9453/attachment.htm>
