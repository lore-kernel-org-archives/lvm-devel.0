From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 23 Apr 2013 10:32:43 +0000 (UTC)
Subject: master - cleanup: improve messages
Message-ID: <20130423103243.D29CD1C6C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2925023411ff9c7a32fa7660617c94a9d9dcd653
Commit:        2925023411ff9c7a32fa7660617c94a9d9dcd653
Parent:        35ab841ecff4a887e70b54b1afb01dd42a4e9cd6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Apr 23 11:58:50 2013 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Apr 23 12:27:33 2013 +0200

cleanup: improve messages

Add verbose message when we will not obtain devices from udev
(i.e. testing is using different udev dir, and the log was
giving misleading info about using udev)

Add proper error message if zalloc from pull would have failed.

Fix typo obolete -> obsolete
---
 lib/commands/toolcontext.c      |    3 +++
 lib/config/config.c             |    6 ++++--
 lib/filters/filter-persistent.c |    4 ++--
 3 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/lib/commands/toolcontext.c b/lib/commands/toolcontext.c
index c42a0bf..8f06285 100644
--- a/lib/commands/toolcontext.c
+++ b/lib/commands/toolcontext.c
@@ -777,6 +777,9 @@ static int _init_dev_cache(struct cmd_context *cmd)
 					udev_dir_len != len;
 
 			if (len_diff || strncmp(DM_UDEV_DEV_DIR, cv->v.str, len)) {
+				log_very_verbose("Non standard udev dir %s, resetting "
+						 "devices/obtain_device_list_from_udev.",
+						 cv->v.str);
 				device_list_from_udev = 0;
 				init_obtain_device_list_from_udev(0);
 			}
diff --git a/lib/config/config.c b/lib/config/config.c
index ad02f5f..e999fc6 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -64,8 +64,10 @@ struct dm_config_tree *config_file_open(const char *filename, int keep_open)
 	if (!cft)
 		return NULL;
 
-	cf = dm_pool_zalloc(cft->mem, sizeof(struct config_file));
-	if (!cf) goto fail;
+	if (!(cf = dm_pool_zalloc(cft->mem, sizeof(struct config_file)))) {
+		log_error("Failed to allocate condig tree.");
+		goto fail;
+	}
 
 	cf->keep_open = keep_open;
 	dm_config_set_custom(cft, cf);
diff --git a/lib/filters/filter-persistent.c b/lib/filters/filter-persistent.c
index bec396b..0d53fce 100644
--- a/lib/filters/filter-persistent.c
+++ b/lib/filters/filter-persistent.c
@@ -103,8 +103,8 @@ int persistent_filter_load(struct dev_filter *f, struct dm_config_tree **cft_out
 
 	if (obtain_device_list_from_udev()) {
 		if (!stat(pf->file, &info)) {
-			log_very_verbose("Obtaining device list from "
-					 "udev. Removing obolete %s.",
+			log_very_verbose("Obtaining device list from udev. "
+					 "Removing obsolete %s.",
 					 pf->file);
 			if (unlink(pf->file) < 0 && errno != EROFS)
 				log_sys_error("unlink", pf->file);


