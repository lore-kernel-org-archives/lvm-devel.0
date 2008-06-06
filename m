From: agk@sourceware.org <agk@sourceware.org>
Date: 6 Jun 2008 11:12:51 -0000
Subject: LVM2/lib cache/lvmcache.c metadata/metadata.c
Message-ID: <20080606111251.15696.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-06-06 11:12:50

Modified files:
	lib/cache      : lvmcache.c 
	lib/metadata   : metadata.c 

Log message:
	cope with volatile vginfo in vg_read

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.54&r2=1.55
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/metadata.c.diff?cvsroot=lvm2&r1=1.177&r2=1.178

--- LVM2/lib/cache/lvmcache.c	2008/06/05 14:24:28	1.54
+++ LVM2/lib/cache/lvmcache.c	2008/06/06 11:12:50	1.55
@@ -243,6 +243,9 @@
 {
 	struct lvmcache_vginfo *vginfo;
 
+	if (!vgname)
+		return vginfo_from_vgid(vgid);
+
 	if (!_vgname_hash)
 		return NULL;
 
--- LVM2/lib/metadata/metadata.c	2008/06/06 09:48:04	1.177
+++ LVM2/lib/metadata/metadata.c	2008/06/06 11:12:50	1.178
@@ -1476,6 +1476,8 @@
  * and call vg_read again).
  *
  * If precommitted is set, use precommitted metadata if present.
+ *
+ * Either of vgname or vgid may be NULL.
  */
 static struct volume_group *_vg_read(struct cmd_context *cmd,
 				     const char *vgname,
@@ -1522,6 +1524,10 @@
 		}
 	}
 
+	/* Now determine the correct vgname if none was supplied */
+	if (!vgname && !(vgname = vgname_from_vgid(cmd->mem, vgid)))
+		return_NULL;
+
 	if (use_precommitted && !(fmt->features & FMT_PRECOMMIT))
 		use_precommitted = 0;
 
@@ -1752,7 +1758,7 @@
 	/* Is corresponding vgname already cached? */
 	if ((vginfo = vginfo_from_vgid(vgid)) &&
 	    vginfo->vgname && !is_orphan_vg(vginfo->vgname)) {
-		if ((vg = _vg_read(cmd, vginfo->vgname, vgid,
+		if ((vg = _vg_read(cmd, NULL, vgid,
 				   &consistent, precommitted)) &&
 		    !strncmp((char *)vg->id.uuid, vgid, ID_LEN)) {
 			if (!consistent) {


