From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Mar 2011 21:57:57 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20110329215757.27165.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-29 21:57:56

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	Use id_equal instead of strncmp()
	
	More consistent and easier to read.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1961&r2=1.1962
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.450&r2=1.451

--- LVM2/WHATS_NEW	2011/03/29 21:34:18	1.1961
+++ LVM2/WHATS_NEW	2011/03/29 21:57:56	1.1962
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Replace several strncmp() calls with id_equal().
   Fix lvmcache_info transfer to orphan_vginfo in _lvmcache_update_vgname().
   Fix -Wold-style-definition gcc warnings.
   Fixes for lvconvert (including --repair) of temporary mirror stacks.
--- LVM2/lib/metadata/metadata.c	2011/03/14 17:00:57	1.450
+++ LVM2/lib/metadata/metadata.c	2011/03/29 21:57:56	1.451
@@ -3043,8 +3043,7 @@
 				continue;
 			}
 
-			if (strncmp((char *)vg->id.uuid,
-			    (char *)correct_vg->id.uuid, ID_LEN)) {
+			if (!id_equal(&vg->id, &correct_vg->id)) {
 				inconsistent = 1;
 				inconsistent_vgid = 1;
 			}
@@ -3292,7 +3291,7 @@
 	    vginfo->vgname && !is_orphan_vg(vginfo->vgname)) {
 		if ((vg = _vg_read(cmd, NULL, vgid, 1,
 				   &consistent, precommitted)) &&
-		    !strncmp((char *)vg->id.uuid, vgid, ID_LEN)) {
+		    id_equal(&vg->id, (const struct id *)vgid)) {
 			if (!consistent)
 				log_error("Volume group %s metadata is "
 					  "inconsistent", vg->name);
@@ -3323,7 +3322,7 @@
 		consistent = 0;
 		if ((vg = _vg_read(cmd, vgname, vgid, 1, &consistent,
 				   precommitted)) &&
-		    !strncmp((char *)vg->id.uuid, vgid, ID_LEN)) {
+		    id_equal(&vg->id, (const struct id *)vgid)) {
 			if (!consistent) {
 				log_error("Volume group %s metadata is "
 					  "inconsistent", vgname);


