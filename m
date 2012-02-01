From: agk@sourceware.org <agk@sourceware.org>
Date: 1 Feb 2012 02:11:44 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20120201021144.598.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-02-01 02:11:43

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	lost line

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.355&r2=1.356

--- LVM2/lib/metadata/lv_manip.c	2012/02/01 02:10:46	1.355
+++ LVM2/lib/metadata/lv_manip.c	2012/02/01 02:11:43	1.356
@@ -1458,6 +1458,8 @@
 			     const struct alloc_parms *alloc_parms, struct alloc_state *alloc_state,
 			     unsigned already_found_one, unsigned iteration_count, unsigned log_iteration_count)
 {
+	unsigned s;
+
 	/* Skip fully-reserved areas (which are not currently removed from the list). */
 	if (!pva->unreserved)
 		return NEXT_AREA;


