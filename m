From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Sep 2014 23:14:54 +0000 (UTC)
Subject: master - memlock: ensure memory is allocation before locking
Message-ID: <20140918231454.354CC611A3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b0bd8ce4086531f4f83ce417ddb988d8b4e0907a
Commit:        b0bd8ce4086531f4f83ce417ddb988d8b4e0907a
Parent:        2263a3bcf559ef1eba68a6ef6216aca4deaf4d3e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 19 01:07:32 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 19 01:12:03 2014 +0200

memlock: ensure memory is allocation before locking

strerror may mmap ram if it was not yet used.
dm_udev_get_sync_support  may initilize udev if it was still not used.
---
 lib/mm/memlock.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/mm/memlock.c b/lib/mm/memlock.c
index a58efd9..0658800 100644
--- a/lib/mm/memlock.c
+++ b/lib/mm/memlock.c
@@ -266,9 +266,6 @@ static int _memlock_maps(struct cmd_context *cmd, lvmlock_t lock, size_t *mstats
 #endif
 	}
 
-	/* Force libc.mo load */
-	if (lock == LVM_MLOCK)
-		(void)strerror(0);
 	/* Reset statistic counters */
 	*mstats = 0;
 
@@ -442,6 +439,9 @@ static void _lock_mem(struct cmd_context *cmd)
 			stack;
 	}
 
+	(void)strerror(0);		/* Force libc.mo load */
+	(void)dm_udev_get_sync_support(); /* udev is initialized */
+
 	log_very_verbose("Locking memory");
 	if (!_memlock_maps(cmd, LVM_MLOCK, &_mstats))
 		stack;


