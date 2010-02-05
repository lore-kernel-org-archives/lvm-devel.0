From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 5 Feb 2010 22:40:50 -0000
Subject: LVM2/tools lvconvert.c pvmove.c
Message-ID: <20100205224050.11114.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2010-02-05 22:40:50

Modified files:
	tools          : lvconvert.c pvmove.c 

Log message:
	Prepare for _get_lvconvert_vg() reuse as part of a larger lvconvert.c
	refactoring.
	
	Document the need to cleanup the "name" args passed around polldaemon,
	lvconvert and pvmove.  It is quite a mess.
	
	Annotate the unused nature of the existing poll_fns->get_copy_vg
	methods' 'uuid' arg.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.116&r2=1.117
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.74&r2=1.75

--- LVM2/tools/lvconvert.c	2010/02/05 21:49:16	1.116
+++ LVM2/tools/lvconvert.c	2010/02/05 22:40:49	1.117
@@ -306,11 +306,16 @@
 }
 
 static struct volume_group *_get_lvconvert_vg(struct cmd_context *cmd,
-					      const char *lv_name, const char *uuid)
+					      const char *name,
+					      const char *uuid __attribute((unused)))
 {
 	dev_close_all();
 
-        return vg_read_for_update(cmd, extract_vgname(cmd, lv_name),
+	if (name && !strchr(name, '/'))
+		return vg_read_for_update(cmd, name, NULL, 0);
+
+	/* 'name' is the full LV name; must extract_vgname() */
+	return vg_read_for_update(cmd, extract_vgname(cmd, name),
 				  NULL, 0);
 }
 
@@ -440,11 +445,19 @@
 int lvconvert_poll(struct cmd_context *cmd, struct logical_volume *lv,
 		   unsigned background)
 {
+	/*
+	 * FIXME allocate an "object key" structure with split
+	 * out members (vg_name, lv_name, uuid, etc) and pass that
+	 * around the lvconvert and polldaemon code
+	 * - will avoid needless work, e.g. extract_vgname()
+	 * - unfortunately there are enough overloaded "name" dragons in
+	 *   the polldaemon, lvconvert, pvmove code that a comprehensive
+	 *   audit/rework is needed
+	 */
 	int len = strlen(lv->vg->name) + strlen(lv->name) + 2;
 	char *uuid = alloca(sizeof(lv->lvid));
 	char *lv_full_name = alloca(len);
 
-
 	if (!uuid || !lv_full_name)
 		return_0;
 
--- LVM2/tools/pvmove.c	2010/01/27 13:29:11	1.74
+++ LVM2/tools/pvmove.c	2010/02/05 22:40:50	1.75
@@ -595,7 +595,8 @@
 }
 
 static struct volume_group *_get_move_vg(struct cmd_context *cmd,
-					 const char *name, const char *uuid)
+					 const char *name,
+					 const char *uuid __attribute((unused)))
 {
 	struct physical_volume *pv;
 


