From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Mar 2012 21:49:33 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/pv_manip.c
Message-ID: <20120301214933.15593.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-01 21:49:32

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : pv_manip.c 

Log message:
	Test alloc fail

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2331&r2=1.2332
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_manip.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32

--- LVM2/WHATS_NEW	2012/03/01 21:21:54	1.2331
+++ LVM2/WHATS_NEW	2012/03/01 21:49:32	1.2332
@@ -1,5 +1,6 @@
 Version 2.02.94 - 
 ====================================
+  Test for alloc fail from _alloc_pv_segment() in _extend_pv().
   Check for alloc fail from get_segtype_from_string() in _lvcreate_params().
   Add _rimage as reserved suffix to lvm.8 man page.
   Improve error logging from mpath filter.
--- LVM2/lib/metadata/pv_manip.c	2011/04/13 18:26:39	1.31
+++ LVM2/lib/metadata/pv_manip.c	2012/03/01 21:49:32	1.32
@@ -442,10 +442,12 @@
 		return 0;
 	}
 
-	peg = _alloc_pv_segment(pv->fmt->cmd->mem, pv,
-				old_pe_count,
-				new_pe_count - old_pe_count,
-				NULL, 0);
+	if (!(peg = _alloc_pv_segment(pv->fmt->cmd->mem, pv,
+				      old_pe_count,
+				      new_pe_count - old_pe_count,
+				      NULL, 0)))
+		return_0;
+
 	dm_list_add(&pv->segments, &peg->list);
 
 	pv->pe_count = new_pe_count;


