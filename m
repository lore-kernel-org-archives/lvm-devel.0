From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  5 Dec 2016 16:15:07 +0000 (UTC)
Subject: master - activation: status check switch to warn
Message-ID: <20161205161507.E3CE060238@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4a4b22e11413ac76164fbdd9b3c353151c8dde70
Commit:        4a4b22e11413ac76164fbdd9b3c353151c8dde70
Parent:        325c2c5687e42afd2c8611e4cefd73f4fb7fb6ed
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 2 13:57:52 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 5 17:04:24 2016 +0100

activation: status check switch to warn

When we can't parse status, switch to warning as this is not
considered an errornous case.  LVS is not supposed to return
error status code when  device is not what it's been expected to
be - but it should be WARNING a user there is something unexpected.
---
 WHATS_NEW                  |    1 +
 lib/activate/dev_manager.c |   29 +++++++++++++++--------------
 2 files changed, 16 insertions(+), 14 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index fbf4f61..3aedebb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Report log_warn when status cannot be parsed.
   Test segment type before accessing segment members when checking status.
   Implement compatible target function for stripe segment.
   Use status info to report merge failed and snapshot invalid lvs fields.
diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index b8b1235..8ace08c 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -126,7 +126,14 @@ static int _get_segment_status_from_target_params(const char *target_name,
 {
 	struct segment_type *segtype;
 
-	seg_status->type = SEG_STATUS_UNKNOWN;
+	seg_status->type = SEG_STATUS_UNKNOWN; /* Parsing failed */
+
+	if (!params) {
+		log_warn("WARNING: Cannot find matching %s segment for %s.",
+			 seg_status->seg->segtype->name,
+			 display_lvname(seg_status->seg->lv));
+		return 0;
+	}
 
 	/*
 	 * TODO: Add support for other segment types too!
@@ -141,19 +148,14 @@ static int _get_segment_status_from_target_params(const char *target_name,
 		if (!(segtype = get_segtype_from_string(seg_status->seg->lv->vg->cmd, TARGET_NAME_SNAPSHOT)))
 			return_0;
 	} else {
-		if (strcmp(target_name, TARGET_NAME_CACHE) &&
-		    strcmp(target_name, TARGET_NAME_SNAPSHOT) &&
-		    strcmp(target_name, TARGET_NAME_THIN_POOL) &&
-		    strcmp(target_name, TARGET_NAME_THIN))
-			return 1; /* TODO: Do not know how to handle yet */
-
 		if (!(segtype = get_segtype_from_string(seg_status->seg->lv->vg->cmd, target_name)))
 			return_0;
 
+		/* Validate segtype from DM table and lvm2 metadata */
 		if (segtype != seg_status->seg->segtype) {
-			log_error(INTERNAL_ERROR "_get_segment_status_from_target_params: "
-				  "segment type %s found does not match expected segment type %s",
-				  segtype->name, seg_status->seg->segtype->name);
+			log_warn("WARNING: segment type %s found does not match "
+				 "expected segment type %s.",
+				 segtype->name, seg_status->seg->segtype->name);
 			return 0;
 		}
 	}
@@ -178,10 +180,9 @@ static int _get_segment_status_from_target_params(const char *target_name,
 		if (!dm_get_status_snapshot(seg_status->mem, params, &seg_status->snapshot))
 			return_0;
 		seg_status->type = SEG_STATUS_SNAPSHOT;
-	} else {
-		log_error(INTERNAL_ERROR "Unsupported segment type %s.", segtype->name);
-		return 0;
-	}
+	} else
+		/* Status not supported */
+		seg_status->type = SEG_STATUS_NONE;
 
 	return 1;
 }


