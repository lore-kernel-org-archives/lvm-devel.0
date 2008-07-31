From: agk@sourceware.org <agk@sourceware.org>
Date: 31 Jul 2008 12:40:52 -0000
Subject: LVM2/tools pvchange.c
Message-ID: <20080731124052.17162.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2008-07-31 12:40:52

Modified files:
	tools          : pvchange.c 

Log message:
	remove unused mdas variable

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvchange.c.diff?cvsroot=lvm2&r1=1.61&r2=1.62

--- LVM2/tools/pvchange.c	2008/07/31 12:28:51	1.61
+++ LVM2/tools/pvchange.c	2008/07/31 12:40:52	1.62
@@ -23,7 +23,6 @@
 	struct volume_group *vg = NULL;
 	const char *vg_name = NULL;
 	struct pv_list *pvl;
-	struct list mdas;
 	uint64_t sector;
 	uint32_t orig_pe_alloc_count;
 	/* FIXME Next three only required for format1. */
@@ -38,8 +37,6 @@
 	int allocatable = 0;
 	int tagarg = 0;
 
-	list_init(&mdas);
-
 	if (arg_count(cmd, addtag_ARG))
 		tagarg = addtag_ARG;
 	else if (arg_count(cmd, deltag_ARG))
@@ -100,7 +97,7 @@
 			return 0;
 		}
 
-		if (!(pv = pv_read(cmd, pv_name, &mdas, &sector, 1))) {
+		if (!(pv = pv_read(cmd, pv_name, NULL, &sector, 1))) {
 			unlock_vg(cmd, vg_name);
 			log_error("Unable to read PV \"%s\"", pv_name);
 			return 0;


