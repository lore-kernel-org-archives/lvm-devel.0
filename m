From: Alasdair Kergon <agk@fedoraproject.org>
Date: Wed, 18 Mar 2015 23:58:12 +0000 (UTC)
Subject: master - cache: Retain orphans while global lock held.
Message-ID: <20150318235812.97BD960392@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=80f4b4b8039a88dfa2648a9b5bb5e16f41b81f87
Commit:        80f4b4b8039a88dfa2648a9b5bb5e16f41b81f87
Parent:        32a6c11877946bfc34a7af0821a793fd62f6bb36
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Wed Mar 18 23:20:09 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Wed Mar 18 23:20:09 2015 +0000

cache: Retain orphans while global lock held.

Fixes segfault when 'pvs' encounters two different PVs sharing the same
uuid but one an orphan, the other in a VG.

If VG_GLOBAL is held, there seems no point in doing a full scan more
than once.

If undesirable side-effects show up, we can try restricting this to
VG_GLOBAL READ locks.  The original code dates back to 2.02.40.
---
 WHATS_NEW            |    1 +
 lib/cache/lvmcache.c |    5 ++++-
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7d0038a..2e50b18 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.118 - 
 =================================
+  Don't invalidate cached orphan information while global lock is held.
   Avoid rescan of all devices when requested pvscan for removed device.
   Measure configuration timestamps with nanoseconds when available.
   Disable lvchange of major and minor of pool LVs.
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 6a9a05f..b8096d7 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -285,6 +285,9 @@ void lvmcache_commit_metadata(const char *vgname)
 
 void lvmcache_drop_metadata(const char *vgname, int drop_precommitted)
 {
+	if (lvmcache_vgname_is_locked(VG_GLOBAL))
+		return;
+
 	/* For VG_ORPHANS, we need to invalidate all labels on orphan PVs. */
 	if (!strcmp(vgname, VG_ORPHANS)) {
 		_drop_metadata(FMT_TEXT_ORPHAN_VG_NAME, 0);
@@ -293,7 +296,7 @@ void lvmcache_drop_metadata(const char *vgname, int drop_precommitted)
 
 		/* Indicate that PVs could now be missing from the cache */
 		init_full_scan_done(0);
-	} else if (!lvmcache_vgname_is_locked(VG_GLOBAL))
+	} else
 		_drop_metadata(vgname, drop_precommitted);
 }
 


