From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Apr 2010 12:14:21 -0000
Subject: LVM2/lib/metadata merge.c
Message-ID: <20100401121421.24584.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-04-01 12:14:21

Modified files:
	lib/metadata   : merge.c 

Log message:
	Limit number of error messages when checking LV segments.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/merge.c.diff?cvsroot=lvm2&r1=1.38&r2=1.39

--- LVM2/lib/metadata/merge.c	2010/03/31 17:23:19	1.38
+++ LVM2/lib/metadata/merge.c	2010/04/01 12:14:20	1.39
@@ -55,6 +55,11 @@
 	return 1;
 }
 
+#define ERROR_MAX 100
+#define inc_error_count \
+	if (error_count++ > ERROR_MAX)	\
+		goto out
+
 /*
  * Verify that an LV's segments are consecutive, complete and don't overlap.
  */
@@ -63,9 +68,9 @@
 	struct lv_segment *seg, *seg2;
 	uint32_t le = 0;
 	unsigned seg_count = 0, seg_found;
-	int r = 1;
 	uint32_t area_multiplier, s;
 	struct seg_list *sl;
+	int error_count = 0;
 
 	dm_list_iterate_items(seg, &lv->segments) {
 		seg_count++;
@@ -73,7 +78,7 @@
 			log_error("LV %s invalid: segment %u should begin at "
 				  "LE %" PRIu32 " (found %" PRIu32 ").",
 				  lv->name, seg_count, le, seg->le);
-			r = 0;
+			inc_error_count;
 		}
 
 		area_multiplier = segtype_is_striped(seg->segtype) ?
@@ -83,7 +88,7 @@
 			log_error("LV %s: segment %u has inconsistent "
 				  "area_len %u",
 				  lv->name, seg_count, seg->area_len);
-			r = 0;
+			inc_error_count;
 		}
 
 		if (complete_vg && seg->log_lv) {
@@ -91,14 +96,14 @@
 				log_error("LV %s: segment %u has log LV but "
 					  "is not mirrored",
 					  lv->name, seg_count);
-				r = 0;
+				inc_error_count;
 			}
 
 			if (!(seg->log_lv->status & MIRROR_LOG)) {
 				log_error("LV %s: segment %u log LV %s is not "
 					  "a mirror log",
 					   lv->name, seg_count, seg->log_lv->name);
-				r = 0;
+				inc_error_count;
 			}
 
 			if (!(seg2 = first_seg(seg->log_lv)) ||
@@ -106,7 +111,7 @@
 				log_error("LV %s: segment %u log LV does not "
 					  "point back to mirror segment",
 					   lv->name, seg_count);
-				r = 0;
+				inc_error_count;
 			}
 		}
 
@@ -116,7 +121,7 @@
 				log_error("LV %s: segment %u mirror image "
 					  "is not mirrored",
 					  lv->name, seg_count);
-				r = 0;
+				inc_error_count;
 			}
 		}
 
@@ -125,7 +130,7 @@
 				log_error("LV %s: segment %u has same LV %s for "
 					  "both origin and snapshot",
 					  lv->name, seg_count, seg->cow->name);
-				r = 0;
+				inc_error_count;
 			}
 		}
 
@@ -134,7 +139,7 @@
 				log_error("LV %s: segment %u has unassigned "
 					  "area %u.",
 					  lv->name, seg_count, s);
-				r = 0;
+				inc_error_count;
 			} else if (seg_type(seg, s) == AREA_PV) {
 				if (!seg_pvseg(seg, s) ||
 				    seg_pvseg(seg, s)->lvseg != seg ||
@@ -142,7 +147,7 @@
 					log_error("LV %s: segment %u has "
 						  "inconsistent PV area %u",
 						  lv->name, seg_count, s);
-					r = 0;
+					inc_error_count;
 				}
 			} else {
 				if (!seg_lv(seg, s) ||
@@ -151,7 +156,7 @@
 					log_error("LV %s: segment %u has "
 						  "inconsistent LV area %u",
 						  lv->name, seg_count, s);
-					r = 0;
+					inc_error_count;
 				}
 
 				if (complete_vg && seg_lv(seg, s) &&
@@ -162,7 +167,7 @@
 					log_error("LV %s: segment %u mirror "
 						  "image %u missing mirror ptr",
 						  lv->name, seg_count, s);
-					r = 0;
+					inc_error_count;
 				}
 
 /* FIXME I don't think this ever holds?
@@ -171,7 +176,7 @@
 						  "inconsistent LV area %u "
 						  "size",
 						  lv->name, seg_count, s);
-					r = 0;
+					inc_error_count;
 				}
  */
 				seg_found = 0;
@@ -184,13 +189,13 @@
 						  lv->name, seg_count,
 						  seg_lv(seg, s)->name,
 						  seg_lv(seg, s)->name, lv->name);
-					r = 0;
+					inc_error_count;
 				} else if (seg_found > 1) {
 					log_error("LV %s has duplicated links "
 						  "to LV %s segment %d",
 						  seg_lv(seg, s)->name,
 						  lv->name, seg_count);
-					r = 0;
+					inc_error_count;
 				}
 			}
 		}
@@ -215,14 +220,14 @@
 				  lv->name, seg->lv->name, seg->le,
 				  seg->le + seg->len - 1,
 				  seg->lv->name, lv->name);
-			r = 0;
+			inc_error_count;
 		} else if (seg_found != sl->count) {
 			log_error("Reference count mismatch: LV %s has %d "
 				  "links to LV %s:%" PRIu32 "-%" PRIu32
 				  ", which has %d links",
 				  lv->name, sl->count, seg->lv->name, seg->le,
 				  seg->le + seg->len - 1, seg_found);
-			r = 0;
+			inc_error_count;
 		}
 
 		seg_found = 0;
@@ -236,17 +241,18 @@
 				  " is incorrectly listed as being used by LV %s",
 				  seg->lv->name, seg->le, seg->le + seg->len - 1,
 				  lv->name);
-			r = 0;
+			inc_error_count;
 		}
 	}
 
 	if (le != lv->le_count) {
 		log_error("LV %s: inconsistent LE count %u != %u",
 			  lv->name, le, lv->le_count);
-		r = 0;
+		inc_error_count;
 	}
 
-	return r;
+out:
+	return !error_count;
 }
 
 /*


