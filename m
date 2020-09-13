From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Sun, 13 Sep 2020 22:16:39 +0000 (GMT)
Subject: master - locking: restore blocking signal for VG_GLOBAL lck
Message-ID: <20200913221639.62B8D3865491@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2101e324f947d1d9d7c4e19996a18b1c88d82742
Commit:        2101e324f947d1d9d7c4e19996a18b1c88d82742
Parent:        fe77d1a71043ca449dbe3a2a635ba0096e4ef9b9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Sep 13 21:10:17 2020 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 14 00:15:14 2020 +0200

locking: restore blocking signal for VG_GLOBAL lck

During removal of a lot of locking code the signal blocking got lost
and signal processing got broken leading to unpredictable
behavior of i.e. activation code the can get interrupted in the
middle of DM table processing.

lvm2 code always expects signals are blocked while lock is held
unless it is explictelly placed into section of:
sigint_allow();....;sigint_restore();
For checking catched interrupt there is sigint_catched();
---
 WHATS_NEW             | 1 +
 lib/locking/locking.c | 8 +++++---
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index afb1b6535..15f4d8e6a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.11 - 
 ==================================
+  Restore lost signal blocking while VG lock is held.
   Improve estimation of needed extents when creating thin-pool.
   Use extra 1% when resizing thin-pool metadata LV with --use-policy.
   Enhance --use-policy percentage rounding.
diff --git a/lib/locking/locking.c b/lib/locking/locking.c
index 65ff8c221..c69f08c09 100644
--- a/lib/locking/locking.c
+++ b/lib/locking/locking.c
@@ -183,7 +183,11 @@ static int _lock_vol(struct cmd_context *cmd, const char *resource, uint32_t fla
 
 	block_signals(flags);
 
-	ret = _locking.lock_resource(cmd, resource, flags, NULL);
+	if ((ret = _locking.lock_resource(cmd, resource, flags, NULL)))
+		/* ensure signals are blocked while VG_GLOBAL lock is held */
+		_update_vg_lock_count(resource, flags);
+	else
+		stack;
 
 	_unblock_signals();
 
@@ -287,8 +291,6 @@ out_hold:
 	else if (lck_type == LCK_UNLOCK)
 		lvmcache_unlock_vgname(resource);
 
-	/* FIXME: we shouldn't need to keep track of this either. */
-	_update_vg_lock_count(resource, flags);
 	return 1;
 
 out_fail:


