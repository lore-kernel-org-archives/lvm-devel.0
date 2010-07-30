From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 30 Jul 2010 16:47:28 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20100730164728.27658.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2010-07-30 16:47:27

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Remove irrelevant comments relating to vg_mda_copies.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.389&r2=1.390

--- LVM2/lib/metadata/metadata.c	2010/07/09 16:57:44	1.389
+++ LVM2/lib/metadata/metadata.c	2010/07/30 16:47:27	1.390
@@ -1199,11 +1199,6 @@
 
 int vg_set_mda_copies(struct volume_group *vg, uint32_t mda_copies)
 {
-	/* FIXME: add checks, etc, and set the value */
-	/*
-	 * FIXME: Before we set a larger value, we may need to
-	 * enable some mdas on PVS
-	 */
 	vg->mda_copies = mda_copies;
 
 	/* FIXME Use log_verbose when this is due to specific cmdline request. */


