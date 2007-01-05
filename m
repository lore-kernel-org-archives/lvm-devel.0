From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 5 Jan 2007 15:53:41 -0000
Subject: LVM2 ./WHATS_NEW lib/metadata/lv_manip.c
Message-ID: <20070105155341.706.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2007-01-05 15:53:41

Modified files:
	.              : WHATS_NEW 
	lib/metadata   : lv_manip.c 

Log message:
	Fix create mirror with name longer than 22 chars.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.525&r2=1.526
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/lv_manip.c.diff?cvsroot=lvm2&r1=1.114&r2=1.115

--- LVM2/WHATS_NEW	2006/12/20 16:19:01	1.525
+++ LVM2/WHATS_NEW	2007/01/05 15:53:40	1.526
@@ -1,5 +1,6 @@
 Version 2.02.18 -
 ====================================
+  Fix create mirror with name longer than 22 chars.
   Fix some activate.c prototypes when compiled without devmapper.
   Fix dmeventd mirror to cope if monitored device disappears.
 
--- LVM2/lib/metadata/lv_manip.c	2006/12/13 03:39:58	1.114
+++ LVM2/lib/metadata/lv_manip.c	2007/01/05 15:53:40	1.115
@@ -1493,7 +1493,7 @@
 	struct cmd_context *cmd = vg->cmd;
 	struct lv_list *ll = NULL;
 	struct logical_volume *lv;
-	char dname[32];
+	char dname[NAME_LEN];
 
 	if (vg->max_lv && (vg->max_lv == vg->lv_count)) {
 		log_error("Maximum number of logical volumes (%u) reached "


