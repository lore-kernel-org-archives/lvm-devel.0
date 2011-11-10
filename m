From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Nov 2011 12:39:02 -0000
Subject: LVM2/lib/metadata lv_manip.c
Message-ID: <20111110123902.2956.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-11-10 12:39:01

Modified files:
	lib/metadata   : lv_manip.c 

Log message:
	Thin disable pool create without activation

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.326&r2=1.327

--- LVM2/lib/metadata/lv_manip.c	2011/11/07 13:54:54	1.326
+++ LVM2/lib/metadata/lv_manip.c	2011/11/10 12:39:01	1.327
@@ -4110,13 +4110,21 @@
 		return NULL;
 	}
 
-	if ((segtype_is_mirrored(lp->segtype) ||
-	     segtype_is_raid(lp->segtype) || seg_is_thin_volume(lp)) && !activation()) {
+	if (!activation() &&
+	    (seg_is_mirrored(lp) ||
+	     seg_is_raid(lp) ||
+	     seg_is_thin_pool(lp))) {
+		/*
+		 * FIXME: For thin pool add some code to allow delayed
+		 * initialization of empty thin pool volume.
+		 * i.e. using some LV flag, fake message,...
+		 * and testing for metadata pool header signature?
+		 */
 		log_error("Can't create %s without using "
 			  "device-mapper kernel driver.",
 			  segtype_is_raid(lp->segtype) ? lp->segtype->name :
 			  segtype_is_mirrored(lp->segtype) ?  "mirror" :
-			  "thin volume");
+			  "thin pool volume");
 		return NULL;
 	}
 


