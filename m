From: wysochanski@sourceware.org <wysochanski@sourceware.org>
Date: 26 Jul 2009 02:30:57 -0000
Subject: LVM2/tools lvcreate.c
Message-ID: <20090726023057.15665.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	wysochanski at sourceware.org	2009-07-26 02:30:57

Modified files:
	tools          : lvcreate.c 

Log message:
	Refactor _lvcreate - move *_ARG into _lvcreate_params and get 'cmd' from 'vg'.
	
	A couple simple refactorings of _lvcreate - should be no functional change.
	Move tags_ARG parsing into _lvcreate_params.  Also use lp->voriginsize
	instread of arg_count().  These refactorings make it easier to move the
	bulk of _lvcreate into the library.
	
	Author: Dave Wysochanski <dwysocha@redhat.com>

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvcreate.c.diff?cvsroot=lvm2&r1=1.199&r2=1.200

--- LVM2/tools/lvcreate.c	2009/07/15 20:02:48	1.199
+++ LVM2/tools/lvcreate.c	2009/07/26 02:30:57	1.200
@@ -53,6 +53,7 @@
 
 	int pv_count;
 	char **pvs;
+	const char *tag;
 };
 
 static int _lvcreate_name_params(struct lvcreate_params *lp,
@@ -525,6 +526,12 @@
 		return 0;
 	}
 
+	if (arg_count(cmd, addtag_ARG) &&
+	    !(lp->tag = arg_str_value(cmd, addtag_ARG, NULL))) {
+		log_error("Failed to get tag");
+		return 0;
+	}
+
 	lp->pv_count = argc;
 	lp->pvs = argv;
 
@@ -593,14 +600,14 @@
 	return lv;
 }
 
-static int _lvcreate(struct cmd_context *cmd, struct volume_group *vg,
+static int _lvcreate(struct volume_group *vg,
 		     struct lvcreate_params *lp)
 {
+	struct cmd_context *cmd = vg->cmd;
 	uint32_t size_rest;
 	uint32_t status = 0;
 	struct logical_volume *lv, *org = NULL;
 	struct dm_list *pvh;
-	const char *tag = NULL;
 	int origin_active = 0;
 	char lv_name_buf[128];
 	const char *lv_name;
@@ -722,7 +729,7 @@
 		/* Must zero cow */
 		status |= LVM_WRITE;
 
-		if (arg_count(cmd, virtualsize_ARG))
+		if (lp->voriginsize)
 			origin_active = 1;
 		else {
 
@@ -806,12 +813,7 @@
 		lv_name = &lv_name_buf[0];
 	}
 
-	if (arg_count(cmd, addtag_ARG)) {
-		if (!(tag = arg_str_value(cmd, addtag_ARG, NULL))) {
-			log_error("Failed to get tag");
-			return 0;
-		}
-
+	if (lp->tag) {
 		if (!(vg->fid->fmt->features & FMT_TAGS)) {
 			log_error("Volume group %s does not support tags",
 				  vg->name);
@@ -846,9 +848,9 @@
 			    lv->minor);
 	}
 
-	if (tag && !str_list_add(cmd->mem, &lv->tags, tag)) {
+	if (lp->tag && !str_list_add(cmd->mem, &lv->tags, lp->tag)) {
 		log_error("Failed to add tag %s to %s/%s",
-			  tag, lv->vg->name, lv->name);
+			  lp->tag, lv->vg->name, lv->name);
 		return 0;
 	}
 
@@ -1000,7 +1002,7 @@
 		return ECMD_FAILED;
 	}
 
-	if (!_lvcreate(cmd, vg, &lp))
+	if (!_lvcreate(vg, &lp))
 		r = ECMD_FAILED;
 
 	unlock_and_release_vg(cmd, vg, lp.vg_name);


