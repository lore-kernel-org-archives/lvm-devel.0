From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 11 Aug 2011 19:17:11 -0000
Subject: LVM2 lib/metadata/raid_manip.c libdm/libdm-dep ...
Message-ID: <20110811191711.22579.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-08-11 19:17:10

Modified files:
	lib/metadata   : raid_manip.c 
	libdm          : libdm-deptree.c 

Log message:
	Add some log_error msg's and fix potential segfault
	
	Thanks to kabi for spotting these - especially the possibility for
	segfault if a loop runs all the way through without finding a match.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/raid_manip.c.diff?cvsroot=lvm2&r1=1.1&r2=1.2
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-deptree.c.diff?cvsroot=lvm2&r1=1.103&r2=1.104

--- LVM2/lib/metadata/raid_manip.c	2011/08/11 18:24:41	1.1
+++ LVM2/lib/metadata/raid_manip.c	2011/08/11 19:17:10	1.2
@@ -179,16 +179,20 @@
 
 		/* Alter rmeta name */
 		shift_name = dm_pool_strdup(cmd->mem, seg_metalv(seg, s)->name);
-		if (!shift_name)
-			return_0;
+		if (!shift_name) {
+			log_error("Memory allocation failed.");
+			return 0;
+		}
 		len = strlen(shift_name) - 1;
 		shift_name[len] -= missing;
 		seg_metalv(seg, s)->name = shift_name;
 
 		/* Alter rimage name */
 		shift_name = dm_pool_strdup(cmd->mem, seg_lv(seg, s)->name);
-		if (!shift_name)
-			return_0;
+		if (!shift_name) {
+			log_error("Memory allocation failed.");
+			return 0;
+		}
 		len = strlen(shift_name) - 1;
 		shift_name[len] -= missing;
 		seg_lv(seg, s)->name = shift_name;
--- LVM2/libdm/libdm-deptree.c	2011/08/02 22:07:23	1.103
+++ LVM2/libdm/libdm-deptree.c	2011/08/11 19:17:10	1.104
@@ -2356,6 +2356,9 @@
 						 dm_segtypes[i].type, size)))
 				return_0;
 
+	if (!seg)
+		return_0;
+
 	seg->region_size = region_size;
 	seg->stripe_size = stripe_size;
 	seg->area_count = 0;


