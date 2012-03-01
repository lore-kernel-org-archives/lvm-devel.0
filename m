From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Mar 2012 21:21:56 -0000
Subject: LVM2 ./WHATS_NEW tools/lvcreate.c
Message-ID: <20120301212156.13159.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-01 21:21:55

Modified files:
	.              : WHATS_NEW 
	tools          : lvcreate.c 

Log message:
	Check for alloc error
	
	Simplify segtype_str usage and check for NULL segtype.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2330&r2=1.2331
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.257&r2=1.258

--- LVM2/WHATS_NEW	2012/03/01 10:39:21	1.2330
+++ LVM2/WHATS_NEW	2012/03/01 21:21:54	1.2331
@@ -1,5 +1,6 @@
 Version 2.02.94 - 
 ====================================
+  Check for alloc fail from get_segtype_from_string() in _lvcreate_params().
   Add _rimage as reserved suffix to lvm.8 man page.
   Improve error logging from mpath filter.
   Check for allocation failure in hold_lock() in clvmd.
--- LVM2/tools/lvcreate.c	2012/02/28 14:24:58	1.257
+++ LVM2/tools/lvcreate.c	2012/03/01 21:21:55	1.258
@@ -652,10 +652,13 @@
 	else
 		segtype_str = "striped";
 
-	lp->segtype = get_segtype_from_string(cmd, arg_str_value(cmd, type_ARG, segtype_str));
+	segtype_str = arg_str_value(cmd, type_ARG, segtype_str);
+
+	if (!(lp->segtype = get_segtype_from_string(cmd, segtype_str)))
+		return_0;
 
 	if (seg_unknown(lp)) {
-		log_error("Unable to create LV with unknown segment type %s.", arg_str_value(cmd, type_ARG, segtype_str));
+		log_error("Unable to create LV with unknown segment type %s.", segtype_str);
 		return 0;
 	}
 


