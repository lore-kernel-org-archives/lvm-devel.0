From: Petr Rockai <prockai@redhat.com>
Date: Tue, 05 Oct 2010 15:51:40 +0200
Subject: [PATCH] automatic snapshot extension with dmeventd (BZ 427298)
Message-ID: <87lj6cn3wz.fsf@twilight.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

the attached patch adds support for automatic snapshot extension. It
uses 2 configuration variables (in lvm.conf):

    # 'snapshot_extend_threshold' and 'snapshot_extend_amount' define how to
    # handle automatic snapshot extension. The former defines when the snapshot
    # should be extended: when its space usage exceeds this many percent. The
    # latter defines how much extra space should be allocated for the snapshot,
    # in percent of its current size.
    #
    # For example, if you set snapshot_extend_threshold to 70 and
    # snapshot_extend_amount to 20, whenever a snapshot exceeds 70% usage, it
    # will be extended by another 20%. For a 1G snapshot, using 700M usage will
    # trigger a resize to 1.2G. When the usage exceeds 840M, the snapshot will
    # be extended to 1.44G, and so on.
    #
    # Setting snapshot_extend_threshold to 100 disables automatic extensions.

    snapshot_extend_threshold = 100
    snapshot_extend_amount = 20

It works by calling lvextend --use-policies every time that the snapshot
use grows by a 5% step, starting at 50% (i.e. it checks at 50, 55, 60,
... 95). The implementation of lvextend --use-policies checks the
configuration options and if the threshold is hit, it extends the
volume. (On a second thought, this 50% should be either relaxed (to 5)
or documented in lvm.conf.)

The patch comes with two automated tests, one testing lvextend
--use-policies directly (test/t-lvextend-snapshot-policy.sh), another
for the dmeventd integration (test/t-lvextend-snapshot-dmeventd.sh).

The latter is somewhat suboptimal, since dmeventd only checks the
snapshot every 10 seconds, so it takes a bit longish. This can be fixed
later though, shouldn't be a real problem for anything.

Yours,
   Petr.

PS: I'll look at the related BZ 189462 next (umount when the snapshot is
invalidated). Shouldn't be too hard, it just needs to find the right
mount point, presumably by consulting /proc/mounts, and use umount2 with
MNT_FORCE and MNT_DETACH. It's probably better not to touch (nor trust)
/etc/mtab.

-------------- next part --------------
A non-text attachment was scrubbed...
Name: dmeventd-snapshot-extend.diff
Type: text/x-diff
Size: 14905 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20101005/1870f9f7/attachment.bin>
