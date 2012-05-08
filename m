From: agk@sourceware.org <agk@sourceware.org>
Date: 8 May 2012 14:31:48 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-config.c
Message-ID: <20120508143148.24375.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-05-08 14:31:46

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-config.c 

Log message:
	Log value chosen in _find_config_bool like other variable types do.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.600&r2=1.601
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-config.c.diff?cvsroot=lvm2&r1=1.23&r2=1.24

--- LVM2/WHATS_NEW_DM	2012/04/24 12:25:12	1.600
+++ LVM2/WHATS_NEW_DM	2012/05/08 14:31:44	1.601
@@ -1,5 +1,6 @@
 Version 1.02.75 - 
 ================================
+  Log value chosen in _find_config_bool like other variable types do.
   Synchronize with dead of dmeventd.
   Rename (Blk)DevNames/DevNos dmsetup header to (Blk)DevNamesUsed/DevNosUsed.
   Add configure --with-veritysetup for independent veritysetup tool.
--- LVM2/libdm/libdm-config.c	2012/03/01 19:54:53	1.23
+++ LVM2/libdm/libdm-config.c	2012/05/08 14:31:45	1.24
@@ -842,22 +842,29 @@
 {
 	const struct dm_config_node *n = find(start, path);
 	const struct dm_config_value *v;
+	int b;
 
-	if (!n)
-		return fail;
+	if (n) {
+		v = n->v;
 
-	v = n->v;
-
-	switch (v->type) {
-	case DM_CFG_INT:
-		return v->v.i ? 1 : 0;
-
-	case DM_CFG_STRING:
-		return _str_to_bool(v->v.str, fail);
-	default:
-		;
+		switch (v->type) {
+		case DM_CFG_INT:
+			b = v->v.i ? 1 : 0;
+			log_very_verbose("Setting %s to %d", path, b);
+			return b;
+
+		case DM_CFG_STRING:
+			b = _str_to_bool(v->v.str, fail);
+			log_very_verbose("Setting %s to %d", path, b);
+			return b;
+		default:
+			;
+		}
 	}
 
+	log_very_verbose("%s not found in config: defaulting to %d",
+			 path, fail);
+
 	return fail;
 }
 


