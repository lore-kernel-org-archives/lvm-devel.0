From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 23 Apr 2009 16:45:32 -0000
Subject: LVM2/tools toollib.c
Message-ID: <20090423164532.13450.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-04-23 16:45:31

Modified files:
	tools          : toollib.c 

Log message:
	Refuse adding missing PVs in create_pv_list in toollib when allocatable_only is
	requested.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/toollib.c.diff?cvsroot=lvm2&r1=1.150&r2=1.151

--- LVM2/tools/toollib.c	2009/04/21 12:59:19	1.150
+++ LVM2/tools/toollib.c	2009/04/23 16:45:30	1.151
@@ -1047,6 +1047,11 @@
 		return 1;
 	}
 
+	if (allocatable_only && (pvl->pv->status & MISSING_PV)) {
+		log_error("Physical volume %s is missing", pvname);
+		return 1;
+	}
+
 	if (allocatable_only &&
 	    (pvl->pv->pe_count == pvl->pv->pe_alloc_count)) {
 		log_err("No free extents on physical volume \"%s\"", pvname);


