From: Dave Wysochanski <dwysocha@redhat.com>
Date: Fri, 10 Jul 2009 11:38:50 -0400
Subject: [PATCH 0/5] Refactor vgremove and move orphan lock inside library, v2
Message-ID: <1247240335-18769-1-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


The following 5 patches refactor vgremove and move the orphan lock inside
a few library calls.  After these patches we will have vgcreate, vgremove,
and vgextend library calls.  The last few patches also reorders VG orphan
locks and VG name locks consistently throughout the code.  Now VG orphan
locks are obtained second.  Previously in most cases they were obtained
first, but in at least one case (vgreduce) they were second.

Passes testsuite and applies on:
commit 7e7274b002956a377d1f02c97d2ba96f4da1de59
Author: Alasdair Kergon <agk@redhat.com>
Date:   Fri Jul 10 09:59:37 2009 +0000

    Add dm_log_with_errno and dm_log_with_errno_init, deprecating the old
    Change plog to use dm_log_with_errno unless deprecated dm_log_init was
used.
    Rename plog macro to LOG_LINE and use in dm_dump_memory_debug.



