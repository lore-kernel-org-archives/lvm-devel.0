From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 12 Oct 2007 21:08:39 -0000
Subject: LVM2/lib/metadata metadata.c
Message-ID: <20071012210839.23324.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2007-10-12 21:08:38

Modified files:
	lib/metadata   : metadata.c 

Log message:
	Remove comment about allocation of pv->vg_name.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.139&r2=1.140

--- LVM2/lib/metadata/metadata.c	2007/10/12 18:37:19	1.139
+++ LVM2/lib/metadata/metadata.c	2007/10/12 21:08:38	1.140
@@ -710,12 +710,6 @@
 
 static void _free_pv(struct dm_pool *mem, struct physical_volume *pv)
 {
-	/*
-	 * FIXME: leak pv->vg_name
-	 * Adding dm_pool_free(mem, pv->vg_name) - causes warning w/'const'
-	 * Perhaps pv->vg_name should be initialized to ORPHAN, not alloc'd
-	 * memory?
-	 */
 	dm_pool_free(mem, pv);
 }
 


