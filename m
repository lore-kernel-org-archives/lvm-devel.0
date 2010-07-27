From: Petr Rockai <prockai@redhat.com>
Date: Tue, 27 Jul 2010 19:17:44 +0200
Subject: [PATCH] Make vgck warn about missing PVs.
Message-ID: <87zkxc9747.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

this is in response to bug #617972 -- read-only commands usually don't
fail when PVs are missing, with the exception of (some cases of)
activation. Since there is demand for programatically checking (without
altering anything) whether a VG is in a good condition, vgck seems like
the right place for this.

I have tweaked tests to cover this functionality, too (one new and one
augmented).

Yours,
   Petr.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: vgck-missing-pvs.diff
Type: text/x-diff
Size: 3480 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20100727/8946ab0e/attachment.bin>
