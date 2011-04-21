From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 21 Apr 2011 13:13:42 -0000
Subject: LVM2 ./WHATS_NEW lib/format_text/format-text.c ...
Message-ID: <20110421131342.20708.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-04-21 13:13:41

Modified files:
	.              : WHATS_NEW 
	lib/format_text: format-text.c 
	lib/metadata   : metadata.c 
Added files:
	test           : t-pv-duplicate.sh 

Log message:
	Fix use of released vgname and vgid
	
	Avoid using of already released memory when duplicated MDA is found.
	
	As get_pv_from_vg_by_id() may call lvmcache_label_scan() use the local copy
	of the vgname and vgid on the stack as vginfo may dissapear and code was
	then accessing garbage in memory.
	
	i.e.  pvs  /dev/loop0
	(when /dev/loop0 and /dev/loop1 has same MDA content)
	
	Invalid read of size 1
	at 0x523C986: dm_hash_lookup (hash.c:325)
	by 0x440C8C: vginfo_from_vgname (lvmcache.c:399)
	by 0x4605C0: _create_vg_text_instance (format-text.c:1882)
	by 0x46140D: _text_create_text_instance (format-text.c:2243)
	by 0x47EB49: _vg_read (metadata.c:2887)
	by 0x47FBD8: vg_read_internal (metadata.c:3231)
	by 0x477594: get_pv_from_vg_by_id (metadata.c:344)
	by 0x45F07A: _get_pv_if_in_vg (format-text.c:1400)
	by 0x45F0B9: _populate_pv_fields (format-text.c:1414)
	by 0x45F40F: _text_pv_read (format-text.c:1493)
	by 0x480431: _pv_read (metadata.c:3500)
	by 0x4802B2: pv_read (metadata.c:3462)
	Address 0x652ab80 is 0 bytes inside a block of size 4 free'd
	at 0x4C2756E: free (vg_replace_malloc.c:366)
	by 0x442277: _free_vginfo (lvmcache.c:963)
	by 0x44235E: _drop_vginfo (lvmcache.c:992)
	by 0x442B23: _lvmcache_update_vgname (lvmcache.c:1165)
	by 0x443449: lvmcache_update_vgname_and_id (lvmcache.c:1358)
	by 0x443C07: lvmcache_add (lvmcache.c:1492)
	by 0x46588C: _text_read (text_label.c:271)
	by 0x466A65: label_read (label.c:289)
	by 0x4413FC: lvmcache_label_scan (lvmcache.c:635)
	by 0x4605AD: _create_vg_text_instance (format-text.c:1881)
	by 0x46140D: _text_create_text_instance (format-text.c:2243)
	by 0x47EB49: _vg_read (metadata.c:2887)
	
	Add testing script

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1972&r2=1.1973
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/format_text/format-text.c.diff?cvsroot=lvm2&r1=1.178&r2=1.179
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.454&r2=1.455
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-pv-duplicate.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1

--- LVM2/WHATS_NEW	2011/04/13 18:26:39	1.1972
+++ LVM2/WHATS_NEW	2011/04/21 13:13:40	1.1973
@@ -1,5 +1,6 @@
 Version 2.02.85 - 
 ===================================
+  Fix use of released memory when duplicate PV is found.
   Add "devices/issue_discards" to lvm.conf.
   Issue discards on lvremove, lvreduce, etc if enabled and supported.
   Fix incorrect tests for dm_snprintf() failure.
--- LVM2/lib/format_text/format-text.c	2011/03/11 15:10:17	1.178
+++ LVM2/lib/format_text/format-text.c	2011/04/21 13:13:40	1.179
@@ -1395,11 +1395,23 @@
 static int _get_pv_if_in_vg(struct lvmcache_info *info,
 			    struct physical_volume *pv)
 {
+	char vgname[NAME_LEN + 1];
+	char vgid[ID_LEN + 1];
+
 	if (info->vginfo && info->vginfo->vgname &&
-	    !is_orphan_vg(info->vginfo->vgname) &&
-	    get_pv_from_vg_by_id(info->fmt, info->vginfo->vgname,
-				 info->vginfo->vgid, info->dev->pvid, pv))
-		return 1;
+	    !is_orphan_vg(info->vginfo->vgname)) {
+		/*
+		 * get_pv_from_vg_by_id() may call
+		 * lvmcache_label_scan() and drop cached
+		 * vginfo so make a local copy of string.
+		 */
+		strcpy(vgname, info->vginfo->vgname);
+		memcpy(vgid, info->vginfo->vgid, sizeof(vgid));
+
+		if (get_pv_from_vg_by_id(info->fmt, vgname, vgid,
+					 info->dev->pvid, pv))
+			return 1;
+	}
 
 	return 0;
 }
--- LVM2/lib/metadata/metadata.c	2011/04/08 14:40:20	1.454
+++ LVM2/lib/metadata/metadata.c	2011/04/21 13:13:40	1.455
@@ -2771,6 +2771,9 @@
  * If precommitted is set, use precommitted metadata if present.
  *
  * Either of vgname or vgid may be NULL.
+ *
+ * Note: vginfo structs must not be held or used as parameters
+ *       across the call to this function.
  */
 static struct volume_group *_vg_read(struct cmd_context *cmd,
 				     const char *vgname,
/cvs/lvm2/LVM2/test/t-pv-duplicate.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-pv-duplicate.sh
+++ -	2011-04-21 13:13:42.016714000 +0000
@@ -0,0 +1,25 @@
+#!/bin/sh
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+# 'Exercise duplicate metadata diagnostics'
+
+. lib/test
+
+aux prepare_devs 3
+
+vgcreate -c n --metadatasize 128k $vg1 $dev1
+
+# copy mda
+dd if=$dev1 of=$dev2 bs=256K count=1
+dd if=$dev1 of=$dev3 bs=256K count=1
+
+pvs $dev1
+vgs $vg1


