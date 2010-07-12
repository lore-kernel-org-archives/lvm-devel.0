From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 12 Jul 2010 12:38:36 -0000
Subject: LVM2/lib/activate activate.c
Message-ID: <20100712123836.1759.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-07-12 12:38:35

Modified files:
	lib/activate   : activate.c 

Log message:
	Addendum for previous patch - show VG/LV name everywhere so the messages
	are consistent.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/activate/activate.c.diff?cvsroot=lvm2&r1=1.172&r2=1.173

--- LVM2/lib/activate/activate.c	2010/07/12 11:37:50	1.172
+++ LVM2/lib/activate/activate.c	2010/07/12 12:38:35	1.173
@@ -263,7 +263,8 @@
 
 	if (!(cn = find_config_tree_node(cmd, "activation/volume_list"))) {
 		log_verbose("activation/volume_list configuration setting "
-			    "not defined, checking host tags only");
+			    "not defined, checking only host tags for %s/%s",
+			    lv->vg->name, lv->name);
 
 		/* If no host tags defined, activate */
 		if (dm_list_empty(&cmd->tags))


