From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue,  7 Oct 2014 00:16:14 +0000 (UTC)
Subject: master - lvmcache: Skip VG_GLOBAL cache lock state update.
Message-ID: <20141007001614.167F96006D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=aeb4d3b740434ed04993e9e7ef74f6e3462efb50
Commit:        aeb4d3b740434ed04993e9e7ef74f6e3462efb50
Parent:        31f10a05544122693143da75bb4a4857cb890226
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Oct 7 00:30:28 2014 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Oct 7 01:15:43 2014 +0100

lvmcache: Skip VG_GLOBAL cache lock state update.

Avoids message:
  Metadata cache has no info for vgname: "#global"
---
 lib/cache/lvmcache.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/lib/cache/lvmcache.c b/lib/cache/lvmcache.c
index 44f586b..416907e 100644
--- a/lib/cache/lvmcache.c
+++ b/lib/cache/lvmcache.c
@@ -367,10 +367,10 @@ void lvmcache_lock_vgname(const char *vgname, int read_only __attribute__((unuse
 	if (!dm_hash_insert(_lock_hash, vgname, (void *) 1))
 		log_error("Cache locking failure for %s", vgname);
 
-	_update_cache_lock_state(vgname, 1);
-
-	if (strcmp(vgname, VG_GLOBAL))
+	if (strcmp(vgname, VG_GLOBAL)) {
+		_update_cache_lock_state(vgname, 1);
 		_vgs_locked++;
+	}
 }
 
 int lvmcache_vgname_is_locked(const char *vgname)
@@ -387,7 +387,8 @@ void lvmcache_unlock_vgname(const char *vgname)
 		log_error(INTERNAL_ERROR "Attempt to unlock unlocked VG %s.",
 			  vgname);
 
-	_update_cache_lock_state(vgname, 0);
+	if (strcmp(vgname, VG_GLOBAL))
+		_update_cache_lock_state(vgname, 0);
 
 	dm_hash_remove(_lock_hash, vgname);
 


