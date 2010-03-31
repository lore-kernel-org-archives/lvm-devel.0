From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Mar 2010 20:26:04 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20100331202604.19745.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2010-03-31 20:26:04

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Attempt to fix non-ALLOC_ANYWHERE allocation code after recent changes broke
	The preference given to the PVs with the largest free areas.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.219&r2=1.220

--- LVM2/lib/metadata/lv_manip.c	2010/03/31 17:23:19	1.219
+++ LVM2/lib/metadata/lv_manip.c	2010/03/31 20:26:04	1.220
@@ -877,8 +877,8 @@
 
 static int _comp_area(const void *l, const void *r)
 {
-	const struct pv_area_used *lhs = *((const struct pv_area_used * const *) l);
-	const struct pv_area_used *rhs = *((const struct pv_area_used * const *) r);
+	const struct pv_area_used *lhs = (const struct pv_area_used *) l;
+	const struct pv_area_used *rhs = (const struct pv_area_used *) r;
 
 	if (lhs->used < rhs->used)
 		return 1;
@@ -1166,10 +1166,7 @@
 						already_found_one = 1;
 					}
 
-					if (ix + ix_offset - 1 < ah->area_count)
-						required = (max_parallel - *allocated) / ah->area_multiple;
-					else
-						required = ah->log_len;
+					required = (max_parallel - *allocated) / ah->area_multiple;
 
 					if (alloc == ALLOC_ANYWHERE) {
 						/*
@@ -1177,6 +1174,8 @@
 						 * into two or more parts.  If the whole stripe doesn't fit,
 						 * reduce amount we're looking for.
 						 */
+						if (ix + ix_offset - 1 >= ah->area_count)
+							required = ah->log_len;
 						if (required >= pva->unreserved) {
 							required = pva->unreserved;
 							pva->unreserved = 0;
@@ -1200,7 +1199,8 @@
 						  (alloc == ALLOC_ANYWHERE) ? pva->unreserved : pva->count - required);
 				}
 			next_pv:
-				if (ix + ix_offset >= ah->area_count + (log_needs_allocating ? ah->log_area_count : 0))
+				if (alloc == ALLOC_ANYWHERE &&
+				    ix + ix_offset >= ah->area_count + (log_needs_allocating ? ah->log_area_count : 0))
 					break;
 			}
 		} while (alloc == ALLOC_ANYWHERE && last_ix != ix && ix < ah->area_count + (log_needs_allocating ? ah->log_area_count : 0));


