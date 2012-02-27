From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 27 Feb 2012 10:15:11 -0000
Subject: LVM2 ./WHATS_NEW lib/raid/raid.c
Message-ID: <20120227101511.17477.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-27 10:15:08

Modified files:
	.              : WHATS_NEW 
	lib/raid       : raid.c 

Log message:
	Test seg pointer for non-null
	
	As the function accepts NULL for 'seg' parameter,
	check for it before dereference.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2313&r2=1.2314
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/raid/raid.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16

--- LVM2/WHATS_NEW	2012/02/27 10:05:35	1.2313
+++ LVM2/WHATS_NEW	2012/02/27 10:15:08	1.2314
@@ -1,5 +1,6 @@
 Version 2.02.94 - 
-====================================                       
+====================================
+  Test seg pointer for non-null it in raid_target_percent error path.
   Check for errors in _init_tags() during config loading.
   Always check result of _set_vg_name() in lvcreate.
   Drop unused call to uname() during clvmd initialization.
--- LVM2/lib/raid/raid.c	2012/02/13 20:13:40	1.15
+++ LVM2/lib/raid/raid.c	2012/02/27 10:15:08	1.16
@@ -230,7 +230,7 @@
 	if (!pos || (sscanf(pos, "%" PRIu64 "/%" PRIu64 "%n",
 			    &numerator, &denominator, &i) != 2)) {
 		log_error("Failed to parse %s status fraction: %s",
-			  seg->segtype->name, params);
+			  (seg) ? seg->segtype->name : "segment", params);
 		return 0;
 	}
 


