From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 10 Feb 2012 14:00:08 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/libdm-report.c
Message-ID: <20120210140008.29465.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-10 14:00:08

Modified files:
	.              : WHATS_NEW_DM 
	libdm          : libdm-report.c 

Log message:
	Do not crash for NULL sort_key
	
	Guard against NULL pointer for sort_key and let it behave like an empty
	string would have been passed in (i.e. no key).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.545&r2=1.546
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-report.c.diff?cvsroot=lvm2&r1=1.46&r2=1.47

--- LVM2/WHATS_NEW_DM	2012/02/10 13:56:19	1.545
+++ LVM2/WHATS_NEW_DM	2012/02/10 14:00:07	1.546
@@ -1,5 +1,6 @@
 Version 1.02.70 - 
 ===================================
+  Do not crash for dm_report_init() sort_key == NULL and behave like "".
   Return error for failing allocation in dm_asprintf().
   Add missing test for failing allocation in dm_realloc() code.
   Add test for memory allocation failures in regex matcher code.
--- LVM2/libdm/libdm-report.c	2011/08/04 14:30:52	1.46
+++ LVM2/libdm/libdm-report.c	2012/02/10 14:00:07	1.47
@@ -541,6 +541,9 @@
 	const char *ws;		/* Word start */
 	const char *we = keys;	/* Word end */
 
+	if (!keys)
+		return 1;
+
 	while (*we) {
 		/* Allow consecutive commas */
 		while (*we && *we == ',')


