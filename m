From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 14 Mar 2012 11:16:01 -0000
Subject: LVM2 ./WHATS_NEW_DM daemons/dmeventd/dmeventd.c
Message-ID: <20120314111601.29527.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2012-03-14 11:16:01

Modified files:
	.              : WHATS_NEW_DM 
	daemons/dmeventd: dmeventd.c 

Log message:
	Do not run a new dmeventd instance on restart if there's no existing one.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.592&r2=1.593
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.96&r2=1.97

--- LVM2/WHATS_NEW_DM	2012/03/12 14:46:53	1.592
+++ LVM2/WHATS_NEW_DM	2012/03/14 11:16:00	1.593
@@ -1,5 +1,6 @@
 Version 1.02.75 - 
 ================================
+  Do not run a new dmeventd instance on restart if there's no existing one.
   Make the time window for reading fifo longer 5sec (1.02.73).
 
 Version 1.02.74 - 6th March 2012
--- LVM2/daemons/dmeventd/dmeventd.c	2012/03/02 23:01:10	1.96
+++ LVM2/daemons/dmeventd/dmeventd.c	2012/03/14 11:16:01	1.97
@@ -1829,13 +1829,13 @@
 
 	if (!init_fifos(&fifos)) {
 		fprintf(stderr, "WARNING: Could not initiate communication with existing dmeventd.\n");
-		return;
+		exit(EXIT_FAILURE);
 	}
 
 	if (!dm_event_get_version(&fifos, &version)) {
 		fprintf(stderr, "WARNING: Could not communicate with existing dmeventd.\n");
 		fini_fifos(&fifos);
-		return;
+		exit(EXIT_FAILURE);
 	}
 
 	if (version < 1) {


