From: agk@sourceware.org <agk@sourceware.org>
Date: 7 Apr 2008 22:12:38 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/metadata.c
Message-ID: <20080407221238.30851.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-04-07 22:12:37

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : metadata.c 

Log message:
	create fids for internal orphan VGs

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.828&r2=1.829
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.165&r2=1.166

--- LVM2/WHATS_NEW	2008/04/07 19:17:29	1.828
+++ LVM2/WHATS_NEW	2008/04/07 22:12:35	1.829
@@ -1,5 +1,6 @@
 Version 2.02.34 -
 ===================================
+  Create a fid for internal orphan VGs.
   Update lvmcache VG lock state for all locking types now.
   Fix output if overriding command_names on cmdline.
   Add detection of clustered mirror log capability.
--- LVM2/lib/metadata/metadata.c	2008/04/04 15:41:20	1.165
+++ LVM2/lib/metadata/metadata.c	2008/04/07 22:12:37	1.166
@@ -1382,6 +1382,15 @@
 		return NULL;
 	}
 
+	/* create format instance with appropriate metadata area */
+	if (!(vg->fid = vginfo->fmt->ops->create_instance(vginfo->fmt,
+							  orphan_vgname, NULL,
+							  NULL))) {
+		log_error("Failed to create format instance");
+		dm_pool_free(cmd->mem, vg);
+		return NULL;
+	}
+
 	list_iterate_items(info, &vginfo->infos) {
 		if (!(pv = _pv_read(cmd, dev_name(info->dev), NULL, NULL, 1))) {
 			continue;


