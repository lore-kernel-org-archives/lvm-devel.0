From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 12 Mar 2012 14:46:54 -0000
Subject: LVM2 ./WHATS_NEW_DM daemons/dmeventd/libdevmap ...
Message-ID: <20120312144654.31151.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-03-12 14:46:53

Modified files:
	.              : WHATS_NEW_DM 
	daemons/dmeventd: libdevmapper-event.c 

Log message:
	We need longer window for checking read from fifo.
	
	Seems like some dmeventd startups are taking more time then expected,
	so make the time window longer here.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.591&r2=1.592
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/libdevmapper-event.c.diff?cvsroot=lvm2&r1=1.48&r2=1.49

--- LVM2/WHATS_NEW_DM	2012/03/06 04:47:37	1.591
+++ LVM2/WHATS_NEW_DM	2012/03/12 14:46:53	1.592
@@ -1,5 +1,6 @@
 Version 1.02.75 - 
 ================================
+  Make the time window for reading fifo longer 5sec (1.02.73).
 
 Version 1.02.74 - 6th March 2012
 ================================
--- LVM2/daemons/dmeventd/libdevmapper-event.c	2012/03/01 10:41:48	1.48
+++ LVM2/daemons/dmeventd/libdevmapper-event.c	2012/03/12 14:46:53	1.49
@@ -245,7 +245,7 @@
 				log_error("Unable to read from event server");
 				return 0;
 			}
-			if ((ret == 0) && i && !bytes) {
+			if ((ret == 0) && (i > 4) && !bytes) {
 				log_error("No input from event server.");
 				return 0;
 			}


