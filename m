From: agk@sourceware.org <agk@sourceware.org>
Date: 7 Jul 2009 16:36:05 -0000
Subject: LVM2/libdm libdm-deptree.c
Message-ID: <20090707163605.18456.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-07-07 16:36:05

Modified files:
	libdm          : libdm-deptree.c 

Log message:
	Fix whitespace in linear target line to fix identical table line detection.
	(only tested with linear so far)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.52&r2=1.53

--- LVM2/libdm/libdm-deptree.c	2009/07/03 12:45:56	1.52
+++ LVM2/libdm/libdm-deptree.c	2009/07/07 16:36:05	1.53
@@ -1252,12 +1252,16 @@
 {
 	struct seg_area *area;
 	char devbuf[DM_FORMAT_DEV_BUFSIZE];
+	unsigned first_time = 1;
 
 	dm_list_iterate_items(area, &seg->areas) {
 		if (!_build_dev_string(devbuf, sizeof(devbuf), area->dev_node))
 			return_0;
 
-		EMIT_PARAMS(*pos, " %s %" PRIu64, devbuf, area->offset);
+		EMIT_PARAMS(*pos, "%s%s %" PRIu64, first_time ? "" : " ",
+			    devbuf, area->offset);
+
+		first_time = 0;
 	}
 
 	return 1;
@@ -1320,7 +1324,7 @@
 		if ((seg->flags & DM_BLOCK_ON_ERROR))
 			EMIT_PARAMS(pos, " block_on_error");
 
-		EMIT_PARAMS(pos, " %u", seg->mirror_area_count);
+		EMIT_PARAMS(pos, " %u ", seg->mirror_area_count);
 
 		break;
 	case SEG_SNAPSHOT:
@@ -1337,10 +1341,10 @@
 		EMIT_PARAMS(pos, "%s", originbuf);
 		break;
 	case SEG_STRIPED:
-		EMIT_PARAMS(pos, "%u %u", seg->area_count, seg->stripe_size);
+		EMIT_PARAMS(pos, "%u %u ", seg->area_count, seg->stripe_size);
 		break;
 	case SEG_CRYPT:
-		EMIT_PARAMS(pos, "%s%s%s%s%s %s %" PRIu64, seg->cipher,
+		EMIT_PARAMS(pos, "%s%s%s%s%s %s %" PRIu64 " ", seg->cipher,
 			    seg->chainmode ? "-" : "", seg->chainmode ?: "",
 			    seg->iv ? "-" : "", seg->iv ?: "", seg->key,
 			    seg->iv_offset != DM_CRYPT_IV_DEFAULT ?


