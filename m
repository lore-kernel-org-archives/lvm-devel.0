From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 8 Feb 2012 11:41:19 -0000
Subject: LVM2 liblvm/lvm_lv.c liblvm/lvm_pv.c tools/vgr ...
Message-ID: <20120208114119.1848.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-08 11:41:18

Modified files:
	liblvm         : lvm_lv.c lvm_pv.c 
	tools          : vgreduce.c 

Log message:
	Remove duplicate test
	
	Tested condition has been already evaluated before
	For strlen() code has already excluded <ID_LEN.
	For repairing, already tested (!argc && !repairing) before.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_lv.c.diff?cvsroot=lvm2&r1=1.36&r2=1.37
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/liblvm/lvm_pv.c.diff?cvsroot=lvm2&r1=1.20&r2=1.21
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/vgreduce.c.diff?cvsroot=lvm2&r1=1.113&r2=1.114

--- LVM2/liblvm/lvm_lv.c	2011/06/01 19:21:04	1.36
+++ LVM2/liblvm/lvm_lv.c	2012/02/08 11:41:18	1.37
@@ -270,12 +270,12 @@
 		log_errno (EINVAL, "Invalid UUID string length");
 		return NULL;
 	}
-	if (strlen(uuid) >= ID_LEN) {
-		if (!id_read_format(&id, uuid)) {
-			log_errno(EINVAL, "Invalid UUID format");
-			return NULL;
-		}
+
+	if (!id_read_format(&id, uuid)) {
+		log_errno(EINVAL, "Invalid UUID format.");
+		return NULL;
 	}
+
 	dm_list_iterate_items(lvl, &vg->lvs) {
 		if (id_equal(&vg->id, &lvl->lv->lvid.id[0]) &&
 		    id_equal(&id, &lvl->lv->lvid.id[1]))
--- LVM2/liblvm/lvm_pv.c	2010/12/14 23:20:58	1.20
+++ LVM2/liblvm/lvm_pv.c	2012/02/08 11:41:18	1.21
@@ -107,12 +107,12 @@
 		log_errno (EINVAL, "Invalid UUID string length");
 		return NULL;
 	}
-	if (strlen(uuid) >= ID_LEN) {
-		if (!id_read_format(&id, uuid)) {
-			log_errno(EINVAL, "Invalid UUID format");
-			return NULL;
-		}
+
+	if (!id_read_format(&id, uuid)) {
+		log_errno(EINVAL, "Invalid UUID format.");
+		return NULL;
 	}
+
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (id_equal(&id, &pvl->pv->id))
 			return pvl->pv;
--- LVM2/tools/vgreduce.c	2011/08/10 20:25:31	1.113
+++ LVM2/tools/vgreduce.c	2012/02/08 11:41:18	1.114
@@ -213,7 +213,7 @@
 		return EINVALID_CMD_LINE;
 	}
 	
-	if (!argc && repairing) {
+	if (!argc) { /* repairing */
 		log_error("Please give volume group name");
 		return EINVALID_CMD_LINE;
 	}


