From: Petr Rockai <prockai@redhat.com>
Date: Tue, 15 Nov 2011 23:00:24 +0100
Subject: [PATCH] Fix RHBZ 754198 (multiple dmeventd snapshot extensions)
Message-ID: <87pqgtxczr.fsf@aldalome.int.mornfall.net.>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

the attached patch should fix the problem encountered in 754198. Namely,
we failed to reset the percent threshold for the next check after
extending a snapshot. To this end, I have added a special exit code,
ENO_ACTION_NEEDED -- however, this is not absolutely required, and is
only an optimisation. On the other hand, it is likely an important
optimisation, because without this, all snapshots filled above 50 % will
run a LVM command (with all the associated overhead) every 10
seconds. There are more possible uses for this new exit code, so I think
it's a good idea anyway.

Documentation *might* need updating (although it's currently only used
by --use-policies, which is not an entirely user-level option...).

Other than that, the patch is relatively straightforward.

Yours,
   Petr

-------------- next part --------------
A non-text attachment was scrubbed...
Name: dmeventd-snapshot-fix.diff
Type: text/x-diff
Size: 3791 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20111115/7bbcffad/attachment.bin>
-------------- next part --------------

-- 
id' Ash = Ash; id' Dust = Dust; id' _ = undefined
