From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 24 Apr 2012 12:25:46 -0000
Subject: LVM2 ./WHATS_NEW_DM daemons/dmeventd/dmeventd.c
Message-ID: <20120424122546.2329.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-04-24 12:25:23

Modified files:
	.              : WHATS_NEW_DM 
	daemons/dmeventd: dmeventd.c 

Log message:
	Synchronize with self-destruction of dmeventd
	
	In some occasional case dmevent restart was experiencing problems
	with obtaining pid lockfile. So this patch tries to send several more kill
	message until daemon kills itself so there is would reponse.
	With this small loop the restart seems to work reliable,
	although the loopsize and usleep are just randomly picked for now.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.599&r2=1.600
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.99&r2=1.100

--- LVM2/WHATS_NEW_DM	2012/04/24 08:24:36	1.599
+++ LVM2/WHATS_NEW_DM	2012/04/24 12:25:12	1.600
@@ -1,5 +1,6 @@
 Version 1.02.75 - 
 ================================
+  Synchronize with dead of dmeventd.
   Rename (Blk)DevNames/DevNos dmsetup header to (Blk)DevNamesUsed/DevNosUsed.
   Add configure --with-veritysetup for independent veritysetup tool.
   Properly support passed in dmevent path in dm_event_register_handler().
--- LVM2/daemons/dmeventd/dmeventd.c	2012/03/15 08:45:55	1.99
+++ LVM2/daemons/dmeventd/dmeventd.c	2012/04/24 12:25:20	1.100
@@ -1893,6 +1893,13 @@
 		exit(EXIT_FAILURE);
 	}
 
+	/* Let's wait a bit till deamon dies - spaming him with messages meanwhile */
+	for (i = 0; i < 10; ++i) {
+		if (daemon_talk(&fifos, &msg, DM_EVENT_CMD_DIE, "-", "-", 0, 0))
+			break; /* yep, it's dead probably */
+		usleep(10);
+	}
+
 	fini_fifos(&fifos);
 }
 


