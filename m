From: David Teigland <teigland@sourceware.org>
Date: Tue, 30 Apr 2019 16:00:21 -0400
Subject: master - lvmcache: remove unused flag
Message-ID: <201904302000.x3UK0L9v020181@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=90b94ead12d739a3221e179bdcf1c482978f0f0f
Commit:        90b94ead12d739a3221e179bdcf1c482978f0f0f
Parent:        d7054cd28ae6bb2fad216f8756ab030de3e8e65e
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 30 14:59:27 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 30 14:59:27 2019 -0500

lvmcache: remove unused flag

The new label scan design is never called recursively,
so we don't need a flag to check for that.
---
 lib/cache/lvmcache.c |    9 ---------
 1 files changed, 0 insertions(+), 9 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index f0b1d56..7d0c60d 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -66,7 +66,6 @@ static struct dm_hash_table *_vgname_hash = NULL;
 static DM_LIST_INIT(_vginfos);
 static DM_LIST_INIT(_found_duplicate_devs);
 static DM_LIST_INIT(_unused_duplicate_devs);
-static int _scanning_in_progress = 0;
 static int _vgs_locked = 0;
 static int _found_duplicate_pvs = 0;	/* If we never see a duplicate PV we can skip checking for them later. */
 static int _found_duplicate_vgnames = 0;
@@ -855,12 +854,6 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 
 	log_debug_cache("Finding VG info");
 
-	/* Avoid recursion when a PVID can't be found! */
-	if (_scanning_in_progress)
-		return 0;
-
-	_scanning_in_progress = 1;
-
 	/* FIXME: can this happen? */
 	if (!cmd->filter) {
 		log_error("label scan is missing filter");
@@ -941,8 +934,6 @@ int lvmcache_label_scan(struct cmd_context *cmd)
 	r = 1;
 
       out:
-	_scanning_in_progress = 0;
-
 	dm_list_iterate_items(vginfo, &_vginfos) {
 		if (is_orphan_vg(vginfo->vgname))
 			continue;


