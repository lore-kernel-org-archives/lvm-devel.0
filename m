From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Dec 2021 15:14:06 +0000 (GMT)
Subject: main - hash: raise hash table size
Message-ID: <20211220151406.16C1A3858411@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=09a4b56895b959f46a9b7e7af11732d8e1bbf945
Commit:        09a4b56895b959f46a9b7e7af11732d8e1bbf945
Parent:        ed1651d11f42ea7157b7b0aebf498b97e56b98aa
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 17 16:36:36 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 20 16:13:28 2021 +0100

hash: raise hash table size

With slightly bigger hash tables, there is considerable
less hash collisions.
---
 WHATS_NEW                       | 1 +
 lib/config/config.c             | 2 +-
 lib/device/dev-cache.c          | 2 +-
 lib/filters/filter-persistent.c | 2 +-
 4 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b0720cd10..fc327dffd 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.15 - 
 ===================================
+  Increase some hash table size to better support large device sets.
 
 Version 2.03.14 - 20th October 2021
 ===================================
diff --git a/lib/config/config.c b/lib/config/config.c
index 0cb0da121..c8dab5683 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1167,7 +1167,7 @@ int config_def_check(struct cft_check_handle *handle)
 	*vp = 0;
 	*rp = 0;
 	if (!handle->cmd->cft_def_hash) {
-		if (!(handle->cmd->cft_def_hash = dm_hash_create(60))) {
+		if (!(handle->cmd->cft_def_hash = dm_hash_create(500))) {
 			log_error("Failed to create configuration definition hash.");
 			r = 0; goto out;
 		}
diff --git a/lib/device/dev-cache.c b/lib/device/dev-cache.c
index 825e348b4..d3fae4948 100644
--- a/lib/device/dev-cache.c
+++ b/lib/device/dev-cache.c
@@ -1246,7 +1246,7 @@ int dev_cache_init(struct cmd_context *cmd)
 	if (!(_cache.mem = dm_pool_create("dev_cache", 10 * 1024)))
 		return_0;
 
-	if (!(_cache.names = dm_hash_create(120)) ||
+	if (!(_cache.names = dm_hash_create(1020)) ||
 	    !(_cache.vgid_index = dm_hash_create(30)) ||
 	    !(_cache.lvid_index = dm_hash_create(29))) {
 		dm_pool_destroy(_cache.mem);
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index 494a38ece..c164c4a99 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -58,7 +58,7 @@ static int _init_hash(struct pfilter *pf)
 	if (pf->devices)
 		dm_hash_destroy(pf->devices);
 
-	if (!(pf->devices = dm_hash_create(111)))
+	if (!(pf->devices = dm_hash_create(511)))
 		return_0;
 
 	return 1;


