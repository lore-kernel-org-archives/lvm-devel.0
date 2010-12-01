From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 1 Dec 2010 10:39:29 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c
Message-ID: <20101201103929.8868.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-12-01 10:39:29

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c 

Log message:
	Check result of vginfo_from_vgname
	
	Check for some potential internal error.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1820&r2=1.1821
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.97&r2=1.98

--- LVM2/WHATS_NEW	2010/12/01 10:33:55	1.1820
+++ LVM2/WHATS_NEW	2010/12/01 10:39:28	1.1821
@@ -1,5 +1,6 @@
 Version 2.02.78 - 
 ====================================
+  Add test for existance of orphan vginfo in _lvmcache_update_vgname().
   Do a full rescan if some device is missing in read_pvs_in_vg().
   Avoid misleading warnings in vgextend --restoremissing in certain cases.
   Add error path stack traces for _process_mapper_dir(), _create_and_load_v4().
--- LVM2/lib/cache/lvmcache.c	2010/10/25 13:33:42	1.97
+++ LVM2/lib/cache/lvmcache.c	2010/12/01 10:39:29	1.98
@@ -1083,6 +1083,13 @@
 		       _scanning_in_progress && _vginfo_is_invalid(primary_vginfo))
 			dm_list_iterate_items_safe(info2, info3, &primary_vginfo->infos) {
 				orphan_vginfo = vginfo_from_vgname(primary_vginfo->fmt->orphan_vg_name, NULL);
+				if (!orphan_vginfo) {
+					log_error(INTERNAL_ERROR "Orphan vginfo %s lost from cache.",
+						  primary_vginfo->fmt->orphan_vg_name);
+					dm_free(vginfo->vgname);
+					dm_free(vginfo);
+					return 0;
+				}
 				_drop_vginfo(info2, primary_vginfo);	
 				_vginfo_attach_info(orphan_vginfo, info2);
 				if (info2->mdas.n)


