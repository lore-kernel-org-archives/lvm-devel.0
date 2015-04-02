From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu,  2 Apr 2015 11:41:10 +0000 (UTC)
Subject: master - lvmcache: skip drop when vg_write lock is not held
Message-ID: <20150402114110.266C96025F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e28e22b9e1e4f7243608aa24ddf43ec63afd1751
Commit:        e28e22b9e1e4f7243608aa24ddf43ec63afd1751
Parent:        f199aeb9eaa1821811f98308565ccc54ab52edf8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 2 12:42:18 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Apr 2 13:38:32 2015 +0200

lvmcache: skip drop when vg_write lock is not held

Commit 80f4b4b8039a88dfa2648a9b5bb5e16f41b81f87
introduced undesirable side-effects for lvm2app user
which happens to be our own python binding.

It appear obtaing pvs list keeps global lock.

So restricting this to VG_GLOBAL READ locks and skip
the drop skip if WRITE lock is held.
---
 WHATS_NEW            |    1 +
 lib/cache/lvmcache.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0a5d797..79136f9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.119 - 
 ==================================
+  Don't skip invalidation of cached orphans if vg write lck is held (2.02.118).
   Log relevant PV tags when using cling allocation.
   Add str_list_add_list() to combine two lists.
   Fix LV processing with selection to always do the selection on initial state.
diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 2b4e2c6..27b4292 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -287,7 +287,7 @@ void lvmcache_commit_metadata(const char *vgname)
 
 void lvmcache_drop_metadata(const char *vgname, int drop_precommitted)
 {
-	if (lvmcache_vgname_is_locked(VG_GLOBAL))
+	if (lvmcache_vgname_is_locked(VG_GLOBAL) && !vg_write_lock_held())
 		return;
 
 	/* For VG_ORPHANS, we need to invalidate all labels on orphan PVs. */


