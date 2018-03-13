From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 13 Mar 2018 08:05:27 -0400
Subject: master - dmsetup: update _display_info
Message-ID: <201803131205.w2DC5RCI002806@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3f351466f7d2789b1f480cd0e370f978df8eb09b
Commit:        3f351466f7d2789b1f480cd0e370f978df8eb09b
Parent:        7ac7cc0ac858462522ef129db4359de69bc6e90d
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 12 11:56:54 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 13 12:58:57 2018 +0100

dmsetup: update _display_info

Handle error code.
---
 tools/dmsetup.c |   21 ++++++++-------------
 1 files changed, 8 insertions(+), 13 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 06eba19..88fb044 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -863,11 +863,6 @@ static int _display_info_cols(struct dm_task *dmt, struct dm_info *info)
 	int selected;
 	char *device_name;
 
-	if (!info->exists) {
-		fprintf(stderr, "Device does not exist.\n");
-		return 0;
-	}
-
 	obj.task = dmt;
 	obj.info = info;
 	obj.deps_task = NULL;
@@ -971,11 +966,6 @@ static void _display_info_long(struct dm_task *dmt, struct dm_info *info)
 	const char *uuid;
 	uint32_t read_ahead;
 
-	if (!info->exists) {
-		fprintf(stderr, "Device does not exist.\n");
-		return;
-	}
-
 	printf("Name:              %s\n", dm_task_get_name(dmt));
 
 	printf("State:             %s%s%s\n",
@@ -1013,17 +1003,22 @@ static void _display_info_long(struct dm_task *dmt, struct dm_info *info)
 static int _display_info(struct dm_task *dmt)
 {
 	struct dm_info info;
+	int r = 1;
 
 	if (!dm_task_get_info(dmt, &info))
 		return_0;
 
+	if (!info.exists) {
+		log_error("Device does not exist.");
+		return 0;
+	}
+
 	if (!_switches[COLS_ARG])
 		_display_info_long(dmt, &info);
 	else
-		/* FIXME return code */
-		_display_info_cols(dmt, &info);
+		r = _display_info_cols(dmt, &info);
 
-	return info.exists ? 1 : 0;
+	return r;
 }
 
 static int _set_task_device(struct dm_task *dmt, const char *name, int optional)


