From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 16 Feb 2022 00:03:08 +0000 (GMT)
Subject: main - dev_manager: fix dm_task_get_device_list
Message-ID: <20220216000308.DD73D3858C1F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6ffb150f3075da69597e6f3e84d7533f2d8a36fa
Commit:        6ffb150f3075da69597e6f3e84d7533f2d8a36fa
Parent:        6626adb46789e329a53242822dc6e9d233320adb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Feb 16 00:33:25 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 16 01:00:36 2022 +0100

dev_manager: fix dm_task_get_device_list

With very old version of DM target driver we have to avoid
trying to use newuuid setting - otherwise we get error
during ioctl preparation phase.

Patch is fixing regression from commit:
988ea0e94c79a496f2619eab878fd9db6168711d
---
 lib/activate/dev_manager.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 6cf4c718c..3fd6aaff7 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -107,6 +107,8 @@ static struct dm_task *_setup_task_run(int task, struct dm_info *info,
 				       int with_flush,
 				       int query_inactive)
 {
+	char vsn[80];
+	unsigned maj, min;
 	struct dm_task *dmt;
 
 	if (!(dmt = dm_task_create(task)))
@@ -142,7 +144,11 @@ static struct dm_task *_setup_task_run(int task, struct dm_info *info,
 	case DM_DEVICE_TARGET_MSG:
 		return dmt; /* TARGET_MSG needs more local tweaking before task_run() */
 	case DM_DEVICE_LIST:
-		if (!dm_task_set_newuuid(dmt, " ")) // new uuid has no meaning here
+		/* Use 'newuuid' only with DM version that supports it */
+		if (driver_version(vsn, sizeof(vsn)) &&
+		    (sscanf(vsn, "%u.%u", &maj, &min) == 2) &&
+		    (maj == 4 ? min >= 19 : maj > 4) &&
+		    !dm_task_set_newuuid(dmt, " ")) // new uuid has no meaning here
 			log_warn("WARNING: Failed to query uuid with LIST.");
 		break;
 	default:


