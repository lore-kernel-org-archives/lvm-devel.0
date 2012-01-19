From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 19 Jan 2012 15:42:19 -0000
Subject: LVM2/lib/thin thin.c
Message-ID: <20120119154219.25768.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-19 15:42:18

Modified files:
	lib/thin       : thin.c 

Log message:
	Thin indent update

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/thin/thin.c.diff?cvsroot=lvm2&r1=1.40&r2=1.41

--- LVM2/lib/thin/thin.c	2012/01/19 15:27:54	1.40
+++ LVM2/lib/thin/thin.c	2012/01/19 15:42:18	1.41
@@ -313,7 +313,7 @@
 	if (!dm_get_status_thin_pool(mem, params, &s))
 		return_0;
 
-        /* With seg report metadata percent, otherwice data percent */
+	/* With 'seg' report metadata percent, otherwice data percent */
 	if (seg) {
 		*percent = make_percent(s->used_metadata_blocks,
 					s->total_metadata_blocks);


