From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 20 Jan 2012 10:55:29 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv.c
Message-ID: <20120120105529.1867.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-01-20 10:55:28

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv.c 

Log message:
	Drop hack in segtype reporting
	
	Since striped name function knows when to report 'linear' instead of
	'stripe' type name - drop it from this place.
	
	This fixes problem when reporting segtype e.g. for thin-pool which
	is also using area_count=1 to store thin data device reference.
	
	It also returns properly strduped memory instead of badly casted const char*.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2226&r2=1.2227
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv.c.diff?cvsroot=lvm2&r1=1.32&r2=1.33

--- LVM2/WHATS_NEW	2012/01/20 03:56:18	1.2226
+++ LVM2/WHATS_NEW	2012/01/20 10:55:28	1.2227
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Do not report linear segtype for non-striped targets.
   Keep info about creation host and time for each logical volume.
   Make error message hit when preallocated memlock memory exceeded clearer.
   Use R lv_attr to indicate read-only activation of non-read-only device in lvs.
--- LVM2/lib/metadata/lv.c	2012/01/19 15:34:33	1.32
+++ LVM2/lib/metadata/lv.c	2012/01/20 10:55:28	1.33
@@ -116,10 +116,6 @@
 
 char *lvseg_segtype_dup(struct dm_pool *mem, const struct lv_segment *seg)
 {
-	if (seg->area_count == 1) {
-		return (char *)"linear";
-	}
-
 	return dm_pool_strdup(mem, seg->segtype->ops->name(seg));
 }
 


