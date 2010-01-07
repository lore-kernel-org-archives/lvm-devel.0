From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 7 Jan 2010 14:32:44 -0000
Subject: LVM2/libdm libdm-report.c
Message-ID: <20100107143244.24155.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-01-07 14:32:44

Modified files:
	libdm          : libdm-report.c 

Log message:
	Error message prints unrecognized key.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-report.c.diff?cvsroot=lvm2&r1=1.31&r2=1.32

--- LVM2/libdm/libdm-report.c	2010/01/07 14:30:47	1.31
+++ LVM2/libdm/libdm-report.c	2010/01/07 14:32:44	1.32
@@ -550,7 +550,7 @@
 		while (*we && *we != ',')
 			we++;
 		if (!_key_match(rh, ws, (size_t) (we - ws), report_type_only)) {
-			log_error("dm_report: Unrecognised field: %.*s",
+			log_error("dm_report: Unrecognised key: %.*s",
 				  (int) (we - ws), ws);
 			return 0;
 		}


