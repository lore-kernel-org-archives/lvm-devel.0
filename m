From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 26 Oct 2010 08:54:38 -0000
Subject: LVM2/daemons/dmeventd dmeventd.c
Message-ID: <20101026085438.8477.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-10-26 08:54:37

Modified files:
	daemons/dmeventd: dmeventd.c 

Log message:
	Update C declaration  () -> (void)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/dmeventd.c.diff?cvsroot=lvm2&r1=1.68&r2=1.69

--- LVM2/daemons/dmeventd/dmeventd.c	2010/10/25 11:57:07	1.68
+++ LVM2/daemons/dmeventd/dmeventd.c	2010/10/26 08:54:37	1.69
@@ -1477,7 +1477,7 @@
 	dm_free(msg.data);
 }
 
-static void _process_initial_registrations()
+static void _process_initial_registrations(void)
 {
 	int i = 0;
 	char *reg;
@@ -1697,7 +1697,7 @@
 	setsid();
 }
 
-static void restart()
+static void restart(void)
 {
 	struct dm_event_fifos fifos;
 	struct dm_event_daemon_message msg = { 0, 0, NULL };


