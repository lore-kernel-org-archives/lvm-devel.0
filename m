From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Oct 2010 13:38:16 -0000
Subject: LVM2/lib/striped striped.c
Message-ID: <20101025133816.9858.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-25 13:38:11

Modified files:
	lib/striped    : striped.c 

Log message:
	Use const config node

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/striped/striped.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33

--- LVM2/lib/striped/striped.c	2010/07/09 15:34:46	1.32
+++ LVM2/lib/striped/striped.c	2010/10/25 13:38:11	1.33
@@ -71,7 +71,7 @@
 static int _striped_text_import(struct lv_segment *seg, const struct config_node *sn,
 			struct dm_hash_table *pv_hash)
 {
-	struct config_node *cn;
+	const struct config_node *cn;
 
 	if ((seg->area_count != 1) &&
 	    !get_config_uint32(sn, "stripe_size", &seg->stripe_size)) {


