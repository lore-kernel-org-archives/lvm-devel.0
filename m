From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 4 Dec 2017 09:57:39 -0500
Subject: master - cleanup: futher code reduction
Message-ID: <201712041457.vB4EvdLT007117@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7379a2624beb6bbefff6f6d6222b1eac9f5980e6
Commit:        7379a2624beb6bbefff6f6d6222b1eac9f5980e6
Parent:        2a22576b2d5b839f30d0dd7fb652920b303366f3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Dec 4 10:38:39 2017 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 4 15:38:50 2017 +0100

cleanup: futher code reduction

Just like everywhere else - use single if() for major:minor setup
(it basically can't fail as of today anyway)

Always leave funtion with correctly set pointers even on error path.
---
 libdm/libdm-deptree.c |   26 ++++++++------------------
 1 files changed, 8 insertions(+), 18 deletions(-)

diff --git a/libdm/libdm-deptree.c b/libdm/libdm-deptree.c
index d6c2693..8fac4a1 100644
--- a/libdm/libdm-deptree.c
+++ b/libdm/libdm-deptree.c
@@ -803,13 +803,11 @@ static int _deps(struct dm_task **dmt, struct dm_pool *mem, uint32_t major, uint
 		 struct dm_info *info, struct dm_deps **deps)
 {
 	memset(info, 0, sizeof(*info));
+	*name = "";
+	*uuid = "";
+	*deps = NULL;
 
 	if (!dm_is_dm_major(major)) {
-		if (name)
-			*name = "";
-		if (uuid)
-			*uuid = "";
-		*deps = NULL;
 		info->major = major;
 		info->minor = minor;
 		return 1;
@@ -820,14 +818,8 @@ static int _deps(struct dm_task **dmt, struct dm_pool *mem, uint32_t major, uint
 		return 0;
 	}
 
-	if (!dm_task_set_major(*dmt, major)) {
-		log_error("_deps: failed to set major for (%" PRIu32 ":%" PRIu32 ")",
-			  major, minor);
-		goto failed;
-	}
-
-	if (!dm_task_set_minor(*dmt, minor)) {
-		log_error("_deps: failed to set minor for (%" PRIu32 ":%" PRIu32 ")",
+	if (!dm_task_set_major(*dmt, major) || !dm_task_set_minor(*dmt, minor)) {
+		log_error("_deps: failed to set major:minor for (" FMTu32 ":" FMTu32 ").",
 			  major, minor);
 		goto failed;
 	}
@@ -850,11 +842,7 @@ static int _deps(struct dm_task **dmt, struct dm_pool *mem, uint32_t major, uint
 		goto failed;
 	}
 
-	if (!info->exists) {
-		*name = "";
-		*uuid = "";
-		*deps = NULL;
-	} else {
+	if (info->exists) {
 		if (info->major != major) {
 			log_error("Inconsistent dtree major number: %u != %u",
 				  major, info->major);
@@ -874,6 +862,8 @@ static int _deps(struct dm_task **dmt, struct dm_pool *mem, uint32_t major, uint
 
 failed:
 	dm_task_destroy(*dmt);
+	*dmt = NULL;
+
 	return 0;
 }
 


