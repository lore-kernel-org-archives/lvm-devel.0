From: David Teigland <teigland@sourceware.org>
Date: Fri, 16 Aug 2019 14:28:38 -0400
Subject: master - lvmcache: replace found_duplicates variable
Message-ID: <201908161828.x7GISclR006503@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=96dfad50224e7e8d3168bd0db93452e819d052b5
Commit:        96dfad50224e7e8d3168bd0db93452e819d052b5
Parent:        677833ce6fcd7596f8dd5857bde90610cd6500c7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Aug 1 13:53:20 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Aug 16 13:26:11 2019 -0500

lvmcache: replace found_duplicates variable

With just checking if the duplicates lists are empty.
---
 lib/cache/lvmcache.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 2634f07..da83b84 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -76,7 +76,6 @@ static DM_LIST_INIT(_initial_duplicates);
 static DM_LIST_INIT(_unused_duplicates);
 static DM_LIST_INIT(_prev_unused_duplicate_devs);
 static int _vgs_locked = 0;
-static int _found_duplicate_pvs = 0;	/* If we never see a duplicate PV we can skip checking for them later. */
 static int _found_duplicate_vgnames = 0;
 
 int lvmcache_init(struct cmd_context *cmd)
@@ -119,7 +118,9 @@ void lvmcache_unlock_vgname(const char *vgname)
 
 bool lvmcache_has_duplicate_devs(void)
 {
-	return _found_duplicate_pvs ? true : false;
+	if (dm_list_empty(&_unused_duplicates) && dm_list_empty(&_initial_duplicates))
+		return false;
+	return true;
 }
 
 int lvmcache_found_duplicate_vgnames(void)
@@ -439,9 +440,6 @@ static void _filter_duplicate_devs(struct cmd_context *cmd)
 			free(devl);
 		}
 	}
-
-	if (dm_list_empty(&_unused_duplicates))
-		_found_duplicate_pvs = 0;
 }
 
 static void _warn_unused_duplicates(struct cmd_context *cmd)
@@ -1851,7 +1849,6 @@ struct lvmcache_info *lvmcache_add(struct labeller *labeller,
 			devl->dev = dev;
 
 			dm_list_add(&_initial_duplicates, &devl->list);
-			_found_duplicate_pvs = 1;
 			if (is_duplicate)
 				*is_duplicate = 1;
 			return NULL;
@@ -1971,7 +1968,6 @@ void lvmcache_destroy(struct cmd_context *cmd, int retain_orphans, int reset)
 	dm_list_splice(&_prev_unused_duplicate_devs, &_unused_duplicates);
 	_destroy_device_list(&_unused_duplicates);
 	_destroy_device_list(&_initial_duplicates); /* should be empty anyway */
-	_found_duplicate_pvs = 0;
 
 	if (retain_orphans) {
 		struct format_type *fmt;


