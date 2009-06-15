From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 15 Jun 2009 12:29:42 -0000
Subject: LVM2 ./WHATS_NEW_DM daemons/dmeventd/libdevmap ...
Message-ID: <20090615122942.3926.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-06-15 12:29:41

Modified files:
	.              : WHATS_NEW_DM 
	daemons/dmeventd: libdevmapper-event.c 

Log message:
	Do not fork daemon when dmeventd cannot be found.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.276&r2=1.277
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/libdevmapper-event.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28

--- LVM2/WHATS_NEW_DM	2009/06/09 16:10:20	1.276
+++ LVM2/WHATS_NEW_DM	2009/06/15 12:29:41	1.277
@@ -1,5 +1,6 @@
 Version 1.02.33 -
 ===============================
+  Do not fork daemon when dmeventd cannot be found.
   Add crypt target handling to libdevmapper node.
   Add splitname command to dmsetup.
   Add subsystem, vg_name, lv_name, lv_layer fields to dmsetup reports.
--- LVM2/daemons/dmeventd/libdevmapper-event.c	2008/11/03 23:01:21	1.27
+++ LVM2/daemons/dmeventd/libdevmapper-event.c	2009/06/15 12:29:41	1.28
@@ -425,6 +425,12 @@
 
       start_server:
 	/* server is not running */
+
+	if (!strncmp(DMEVENTD_PATH, "/", 1) && stat(DMEVENTD_PATH, &statbuf)) {
+		log_error("Unable to find dmeventd.");
+		return_0;
+	}
+
 	pid = fork();
 
 	if (pid < 0)


