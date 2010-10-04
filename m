From: Petr Rockai <prockai@redhat.com>
Date: Tue, 05 Oct 2010 00:02:29 +0200
Subject: [PATCH] binary backups & pvcreate --undo (take 4)
Message-ID: <87r5g5wr9m.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I am attaching another rebase of the binary backup code. It passes the
testsuite (the attached patch enables binary backups for all of the
testsuite, although that might be gratuitous) and should apply cleanly
on top of current CVS. It also comes with a testcase for pvcreate --undo
itself, test/t-pvcreate-undo.sh.

The functionality is limited to pvcreate, but lvcreate --zero shouldn't
be too hard to add. I would however prefer to have this merged first
(since it's been around for a long time) before adding any more features
to the bundle.

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: binbackup-4.diff
Type: text/x-diff
Size: 51803 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20101005/1545e2f6/attachment.bin>
