From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 29 Mar 2011 21:34:19 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c
Message-ID: <20110329213419.30234.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-29 21:34:18

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c 

Log message:
	Fix access to released memory
	
	Invalid primary_vginfo was supposed to move all its lvmcache_infos to
	orphan_vginfo - however it has called _drop_vginfo() inside the loop
	that released primary_vginfo itself - thus made the loop using released
	memory.
	
	Use _vginfo_detach_info() instead and call _drop_vginfo after
	th loop is finished.
	
	Valgrind trace it should fix:
	
	Invalid read of size 8
	at 0x41E960: _lvmcache_update_vgname (lvmcache.c:1229)
	by 0x41EF86: lvmcache_update_vgname_and_id (lvmcache.c:1360)
	by 0x441393: _text_read (text_label.c:329)
	by 0x442221: label_read (label.c:289)
	by 0x41CF92: lvmcache_label_scan (lvmcache.c:635)
	by 0x45B303: _vg_read_by_vgid (metadata.c:3342)
	by 0x45B4A6: lv_from_lvid (metadata.c:3381)
	by 0x41B555: lv_activation_filter (activate.c:1346)
	by 0x415868: do_activate_lv (lvm-functions.c:343)
	by 0x415E8C: do_lock_lv (lvm-functions.c:532)
	by 0x40FD5F: do_command (clvmd-command.c:120)
	by 0x413D7B: process_local_command (clvmd.c:1686)
	Address 0x63eba10 is 16 bytes inside a block of size 160 free'd
	at 0x4C2756E: free (vg_replace_malloc.c:366)
	by 0x41DE70: _free_vginfo (lvmcache.c:980)
	by 0x41DEDA: _drop_vginfo (lvmcache.c:998)
	by 0x41E854: _lvmcache_update_vgname (lvmcache.c:1238)
	by 0x41EF86: lvmcache_update_vgname_and_id (lvmcache.c:1360)
	by 0x441393: _text_read (text_label.c:329)
	by 0x442221: label_read (label.c:289)
	by 0x41CF92: lvmcache_label_scan (lvmcache.c:635)
	by 0x45B303: _vg_read_by_vgid (metadata.c:3342)
	by 0x45B4A6: lv_from_lvid (metadata.c:3381)
	by 0x41B555: lv_activation_filter (activate.c:1346)
	by 0x415868: do_activate_lv (lvm-functions.c:343)
	
	problematic line:
	dm_list_iterate_items_safe(info2, info3, &primary_vginfo->infos)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1960&r2=1.1961
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.107&r2=1.108

--- LVM2/WHATS_NEW	2011/03/29 21:05:39	1.1960
+++ LVM2/WHATS_NEW	2011/03/29 21:34:18	1.1961
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Fix lvmcache_info transfer to orphan_vginfo in _lvmcache_update_vgname().
   Fix -Wold-style-definition gcc warnings.
   Fixes for lvconvert (including --repair) of temporary mirror stacks.
   Mitigate annoying error warning from device is usable check if run as non-root.
--- LVM2/lib/cache/lvmcache.c	2011/03/13 23:01:08	1.107
+++ LVM2/lib/cache/lvmcache.c	2011/03/29 21:34:18	1.108
@@ -1107,17 +1107,17 @@
 		 * Otherwise we risk bogus warnings of duplicate VGs.
 		 */
 		while ((primary_vginfo = vginfo_from_vgname(vgname, NULL)) &&
-		       _scanning_in_progress && _vginfo_is_invalid(primary_vginfo))
+		       _scanning_in_progress && _vginfo_is_invalid(primary_vginfo)) {
+			orphan_vginfo = vginfo_from_vgname(primary_vginfo->fmt->orphan_vg_name, NULL);
+			if (!orphan_vginfo) {
+				log_error(INTERNAL_ERROR "Orphan vginfo %s lost from cache.",
+					  primary_vginfo->fmt->orphan_vg_name);
+				dm_free(vginfo->vgname);
+				dm_free(vginfo);
+				return 0;
+			}
 			dm_list_iterate_items_safe(info2, info3, &primary_vginfo->infos) {
-				orphan_vginfo = vginfo_from_vgname(primary_vginfo->fmt->orphan_vg_name, NULL);
-				if (!orphan_vginfo) {
-					log_error(INTERNAL_ERROR "Orphan vginfo %s lost from cache.",
-						  primary_vginfo->fmt->orphan_vg_name);
-					dm_free(vginfo->vgname);
-					dm_free(vginfo);
-					return 0;
-				}
-				_drop_vginfo(info2, primary_vginfo);	
+				_vginfo_detach_info(info2);
 				_vginfo_attach_info(orphan_vginfo, info2);
 				if (info2->mdas.n)
 					sprintf(mdabuf, " with %u mdas",
@@ -1129,6 +1129,10 @@
 					  vgname, orphan_vginfo->vgid[0] ? " (" : "",
 					  orphan_vginfo->vgid[0] ? orphan_vginfo->vgid : "",
 					  orphan_vginfo->vgid[0] ? ")" : "", mdabuf);
+			}
+
+			if (!_drop_vginfo(NULL, primary_vginfo))
+				return_0;
 		}
 
 		if (!_insert_vginfo(vginfo, vgid, vgstatus, creation_host,


