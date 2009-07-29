From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 29 Jul 2009 14:34:15 -0500
Subject: [PATCH] LVM, fix mirror ctr table arguments
Message-ID: <1248896055.532.4.camel@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

The device-mapper table is being constructed incorrectly WRT
the upstream kernel.  "block_on_error" is no longer an argument
to the log module, but rather the "features" section of the
mirror CTR table.

Also in this patch are the changes necessary to construct the
mapping tables for cluster mirroring - given the recent inclusion
of dm-log-userspace.

(Patch is '-p0' not '-p1'.)

 brassow

Index: libdm/libdm-deptree.c
===================================================================
RCS file: /cvs/lvm2/LVM2/libdm/libdm-deptree.c,v
retrieving revision 1.53
diff -p -u -r1.53 libdm-deptree.c
--- libdm/libdm-deptree.c	7 Jul 2009 16:36:05 -0000	1.53
+++ libdm/libdm-deptree.c	29 Jul 2009 19:28:17 -0000
@@ -1291,12 +1291,6 @@ static int _emit_segment_line(struct dm_
 		if (seg->flags & DM_CORELOG)
 			log_parm_count--;   /* DM_CORELOG does not count in the param list */
 
-		if (seg->clustered) {
-			if (seg->uuid)
-				log_parm_count++;
-			EMIT_PARAMS(pos, "clustered-");
-		}
-
 		if (!seg->log)
 			logtype = "core";
 		else {
@@ -1306,24 +1300,25 @@ static int _emit_segment_line(struct dm_
 				return_0;
 		}
 
-		EMIT_PARAMS(pos, "%s %u", logtype, log_parm_count);
+		if (seg->clustered) {
+			if (!seg->uuid)
+				return_0;
+			log_parm_count++;
+			EMIT_PARAMS(pos, "userspace %u %s clustered-%s",
+				    log_parm_count, seg->uuid, logtype);
+		} else
+			EMIT_PARAMS(pos, "%s %u", logtype, log_parm_count);
 
 		if (seg->log)
 			EMIT_PARAMS(pos, " %s", logbuf);
 
 		EMIT_PARAMS(pos, " %u", seg->region_size);
 
-		if (seg->clustered && seg->uuid)
-			EMIT_PARAMS(pos, " %s", seg->uuid);
-
 		if ((seg->flags & DM_NOSYNC))
 			EMIT_PARAMS(pos, " nosync");
 		else if ((seg->flags & DM_FORCESYNC))
 			EMIT_PARAMS(pos, " sync");
 
-		if ((seg->flags & DM_BLOCK_ON_ERROR))
-			EMIT_PARAMS(pos, " block_on_error");
-
 		EMIT_PARAMS(pos, " %u ", seg->mirror_area_count);
 
 		break;
@@ -1369,6 +1364,10 @@ static int _emit_segment_line(struct dm_
 		break;
 	}
 
+	if ((seg->type == SEG_MIRRORED) &&
+	    (seg->flags & DM_BLOCK_ON_ERROR))
+		EMIT_PARAMS(pos, " 1 handle_errors");
+
 	log_debug("Adding target to (%" PRIu32 ":%" PRIu32 "): %" PRIu64
 		  " %" PRIu64 " %s %s", major, minor,
 		  *seg_start, seg->size, dm_segtypes[seg->type].target, params);



