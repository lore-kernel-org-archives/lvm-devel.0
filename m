From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 15 Feb 2012 01:44:59 -0000
Subject: LVM2/lib format1/format1.c format_pool/format_ ...
Message-ID: <20120215014459.30369.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-15 01:44:59

Modified files:
	lib/format1    : format1.c 
	lib/format_pool: format_pool.c 

Log message:
	Fix pool names of the format1/format_pool orphan VGs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format1/format1.c.diff?cvsroot=lvm2&r1=1.146&r2=1.147
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_pool/format_pool.c.diff?cvsroot=lvm2&r1=1.50&r2=1.51

--- LVM2/lib/format1/format1.c	2012/02/13 11:03:59	1.146
+++ LVM2/lib/format1/format1.c	2012/02/15 01:44:58	1.147
@@ -603,7 +603,7 @@
 		return NULL;
 	}
 
-	if (!(fmt->orphan_vg = alloc_vg("text_orphan", cmd, fmt->orphan_vg_name))) {
+	if (!(fmt->orphan_vg = alloc_vg("format1_orphan", cmd, fmt->orphan_vg_name))) {
 		log_error("Couldn't create lvm1 orphan VG.");
 		dm_free(fmt);
 		return NULL;
--- LVM2/lib/format_pool/format_pool.c	2012/02/13 11:04:00	1.50
+++ LVM2/lib/format_pool/format_pool.c	2012/02/15 01:44:59	1.51
@@ -314,7 +314,7 @@
 		return NULL;
 	}
 
-	if (!(fmt->orphan_vg = alloc_vg("text_orphan", cmd, fmt->orphan_vg_name))) {
+	if (!(fmt->orphan_vg = alloc_vg("pool_orphan", cmd, fmt->orphan_vg_name))) {
 		log_error("Couldn't create lvm1 orphan VG.");
 		dm_free(fmt);
 		return NULL;


