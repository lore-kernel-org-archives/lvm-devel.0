From: Petr Rockai <prockai@redhat.com>
Date: Wed, 31 Mar 2010 02:28:54 +0200
Subject: [PATCH] binary backups / pvcreate --undo, take 3
Message-ID: <87wrwt8hbt.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

I have rebased the latest incarnation of the patch and fixed it up a
little. It includes a simple testcase. Patch against recent CVS
(excluding the allocation changes, which fail the testsuite, but there
should be no conflicts with these...)

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: binbackup.diff
Type: text/x-diff
Size: 48799 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100331/24d05d6b/attachment.bin>
