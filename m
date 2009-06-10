From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 10 Jun 2009 15:27:57 -0000
Subject: LVM2/tools lvconvert.c
Message-ID: <20090610152757.26344.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-06-10 15:27:57

Modified files:
	tools          : lvconvert.c 

Log message:
	Complain when lvconvert --repair is used on non-mirror LV.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvconvert.c.diff?cvsroot=lvm2&r1=1.78&r2=1.79

--- LVM2/tools/lvconvert.c	2009/06/04 12:01:16	1.78
+++ LVM2/tools/lvconvert.c	2009/06/10 15:27:57	1.79
@@ -894,6 +894,11 @@
 		return ECMD_FAILED;
 	}
 
+	if (arg_count(cmd, repair_ARG) && !(lv->status & MIRRORED)) {
+		log_error("Can't repair non-mirrored LV \"%s\".", lv->name);
+		return ECMD_FAILED;
+	}
+
 	if (lp->snapshot) {
 		if (lv->status & MIRRORED) {
 			log_error("Unable to convert mirrored LV \"%s\" into a snapshot.", lv->name);


