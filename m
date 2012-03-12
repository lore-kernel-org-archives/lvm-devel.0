From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 12 Mar 2012 14:41:43 -0000
Subject: LVM2/lib/metadata merge.c
Message-ID: <20120312144143.27870.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-12 14:41:42

Modified files:
	lib/metadata   : merge.c 

Log message:
	Using %u modifier to print unsigned values.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/merge.c.diff?cvsroot=lvm2&r1=1.57&r2=1.58

--- LVM2/lib/metadata/merge.c	2012/01/24 00:55:03	1.57
+++ LVM2/lib/metadata/merge.c	2012/03/12 14:41:42	1.58
@@ -204,7 +204,7 @@
 
 				if (seg->chunk_size < DM_THIN_MIN_DATA_BLOCK_SIZE ||
 				    seg->chunk_size > DM_THIN_MAX_DATA_BLOCK_SIZE) {
-					log_error("LV %s: thin pool segment %u  chunk size %d is out of range",
+					log_error("LV %s: thin pool segment %u has chunk size %u out of range.",
 						  lv->name, seg_count, seg->chunk_size);
 					inc_error_count;
 				}
@@ -240,7 +240,7 @@
 				}
 
 				if (seg->device_id > DM_THIN_MAX_DEVICE_ID) {
-					log_error("LV %s: thin volume segment %u has too large device id %d",
+					log_error("LV %s: thin volume segment %u has too large device id %u",
 						  lv->name, seg_count, seg->device_id);
 					inc_error_count;
 				}
@@ -316,7 +316,7 @@
 						seg_found++;
 
 				if (!seg_found) {
-					log_error("LV %s segment %d uses LV %s,"
+					log_error("LV %s segment %u uses LV %s,"
 						  " but missing ptr from %s to %s",
 						  lv->name, seg_count,
 						  seg_lv(seg, s)->name,
@@ -324,7 +324,7 @@
 					inc_error_count;
 				} else if (seg_found > 1) {
 					log_error("LV %s has duplicated links "
-						  "to LV %s segment %d",
+						  "to LV %s segment %u",
 						  seg_lv(seg, s)->name,
 						  lv->name, seg_count);
 					inc_error_count;
@@ -383,9 +383,9 @@
 				  seg->lv->name, lv->name);
 			inc_error_count;
 		} else if (seg_found != sl->count) {
-			log_error("Reference count mismatch: LV %s has %d "
+			log_error("Reference count mismatch: LV %s has %u "
 				  "links to LV %s:%" PRIu32 "-%" PRIu32
-				  ", which has %d links",
+				  ", which has %u links",
 				  lv->name, sl->count, seg->lv->name, seg->le,
 				  seg->le + seg->len - 1, seg_found);
 			inc_error_count;


