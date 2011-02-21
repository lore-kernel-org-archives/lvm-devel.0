From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 21 Feb 2011 13:09:28 -0000
Subject: LVM2/lib/metadata pv_manip.c
Message-ID: <20110221130928.31891.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2011-02-21 13:09:27

Modified files:
	lib/metadata   : pv_manip.c 

Log message:
	%ld -> PRIu64

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/metadata/pv_manip.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27

--- LVM2/lib/metadata/pv_manip.c	2011/02/21 12:27:26	1.26
+++ LVM2/lib/metadata/pv_manip.c	2011/02/21 13:09:27	1.27
@@ -436,7 +436,7 @@
 	uint32_t old_pe_count, new_pe_count = 0;
 
 	if (size < pv_min_size()) {
-		log_error("Size must exceed minimum of %ld sectors on PV %s.",
+		log_error("Size must exceed minimum of %" PRIu64 " sectors on PV %s.",
 			   pv_min_size(), pv_dev_name(pv));
 		return 0;
 	}


