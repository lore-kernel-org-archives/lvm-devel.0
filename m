From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  5 Dec 2016 16:15:10 +0000 (UTC)
Subject: master - activation: improve error handling for status reading
Message-ID: <20161205161510.0086060238@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5ba2d58d28ace811c33e7e66b777fcca3f42149e
Commit:        5ba2d58d28ace811c33e7e66b777fcca3f42149e
Parent:        4a4b22e11413ac76164fbdd9b3c353151c8dde70
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Dec 1 10:37:03 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 5 17:05:17 2016 +0100

activation: improve error handling for status reading

When lvm2 wants to see a status, it needs to validate,
segment for status reading is matching whan lvm2 expects in
metadata.

Also ensure status failure will not cause '0' from info reading
when actual info was collected properly.
Failure in 'status' reading is considered to be
a 'log_warn()' event only.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |   28 +++++++++++++++-------------
 2 files changed, 16 insertions(+), 13 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3aedebb..0f5ed02 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Fix matching of LV segment when checking for it info status.
   Report log_warn when status cannot be parsed.
   Test segment type before accessing segment members when checking status.
   Implement compatible target function for stripe segment.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 8ace08c..56c6d1d 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -203,9 +203,8 @@ static int _info_run(info_type_t type, const char *name, const char *dlid,
 	struct dm_task *dmt;
 	int dmtask;
 	void *target = NULL;
-	uint64_t target_start, target_length;
-	char *target_name, *target_params, *params_to_process = NULL;
-	uint32_t extent_size;
+	uint64_t target_start, target_length, start, length;
+	char *target_name, *target_params;
 	int with_flush = 1; /* TODO: arg for _info_run */
 
 	switch (type) {
@@ -240,21 +239,24 @@ static int _info_run(info_type_t type, const char *name, const char *dlid,
 	} else if (read_ahead)
 		*read_ahead = DM_READ_AHEAD_NONE;
 
-	if (type == STATUS) {
-		extent_size = seg_status->seg->lv->vg->extent_size;
+	/* Query status only for active device */
+	if ((type == STATUS) && dminfo->exists) {
+		start = length = seg_status->seg->lv->vg->extent_size;
+		start *= seg_status->seg->le;
+		length *= seg_status->seg->len;
+
 		do {
 			target = dm_get_next_target(dmt, target, &target_start,
 						    &target_length, &target_name, &target_params);
-			if (((uint64_t) seg_status->seg->le * extent_size == target_start) &&
-			    ((uint64_t) seg_status->seg->len * extent_size == target_length)) {
-				params_to_process = target_params;
-				break;
-			}
+
+			if ((start == target_start) && (length == target_length))
+				break; /* Keep target_params when matching segment is found */
+
+			target_params = NULL; /* Marking this target_params unusable */
 		} while (target);
 
-		if (params_to_process &&
-		    !_get_segment_status_from_target_params(target_name, params_to_process, seg_status))
-			goto_out;
+		if (!_get_segment_status_from_target_params(target_name, target_params, seg_status))
+			stack;
 	}
 
 	r = 1;


