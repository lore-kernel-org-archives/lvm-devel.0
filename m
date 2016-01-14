From: David Teigland <teigland@fedoraproject.org>
Date: Thu, 14 Jan 2016 19:39:27 +0000 (UTC)
Subject: master - Revert "lvmcache: skip drop when vg_write lock is not held"
Message-ID: <20160114193927.2331960C5B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e710bac03d2625a50131ac325ad90f0d4f6f3d51
Commit:        e710bac03d2625a50131ac325ad90f0d4f6f3d51
Parent:        b82d5ee0926acee37356f5a322edbb4694081699
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Jan 14 13:26:15 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Jan 14 13:34:36 2016 -0600

Revert "lvmcache: skip drop when vg_write lock is not held"

This reverts e28e22b9e1e4f7243608aa24ddf43ec63afd1751
The problem that that commit was fixing (pytest failure)
no longer appears with the current code, so the commit is
not needed.

That commit is a problem for pvchange, because it prevents
lvmcache from retaining VG metadata even while the global
lock is held.  pvchange holds the global lock to ensure
that VG metadata is kept in lvmcache throughout processing.
If the cache is not kept, a PV with zero MDAs will appear
first in its actual VG and then appear again in the orphan VG.
It wrongly appears a second time in the orphan VG only if
the actual VG is dropped from lvmcache.
---
 lib/cache/lvmcache.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 998ea6f..1363e93 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -332,7 +332,7 @@ void lvmcache_commit_metadata(const char *vgname)
 
 void lvmcache_drop_metadata(const char *vgname, int drop_precommitted)
 {
-	if (lvmcache_vgname_is_locked(VG_GLOBAL) && !vg_write_lock_held())
+	if (lvmcache_vgname_is_locked(VG_GLOBAL))
 		return;
 
 	/* For VG_ORPHANS, we need to invalidate all labels on orphan PVs. */


