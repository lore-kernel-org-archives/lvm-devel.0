From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Mon, 08 Jan 2007 12:11:46 -0500
Subject: [LVM2 PATCH] (3/5) Allocate mirror log first
In-Reply-To: <45A2751E.5010707@ce.jp.nec.com>
References: <45A2751E.5010707@ce.jp.nec.com>
Message-ID: <45A27B52.80601@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch allows log allocation first to fix the problems that
lvconvert from linear to mirror and lvconvert from corelog to disklog
may allocate log from the same PV as mirror images.

What is the problem?
  - Different (stronger) constraint should be applied to log area.
    i.e. log must avoid all parallel areas, not only the ones
    corresponding to the current LE.
    In other words, _find_parallel_space() should use ah->parallel_areas
    as whole for log allocation constraint. Whereas the part of it
    (parallel_pvs) is used for the other allocation.

To fix it, this patch tries log allocation first and then others.

As a result of this change,
"--alloc anywhere" for mirror with log on the same device also starts
working. (It currently doesn't.)

Moving auto variables initialization after "restart" label
is not necessary but for avoiding future problem.


Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America

-------------- next part --------------
A non-text attachment was scrubbed...
Name: 03-allocate-mirror-log-first.patch
Type: text/x-patch
Size: 5896 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20070108/d1bb0c43/attachment.bin>
