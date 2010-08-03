From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 3 Aug 2010 12:56:01 -0000
Subject: LVM2 ./WHATS_NEW_DM tools/dmsetup.c
Message-ID: <20100803125601.26621.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-08-03 12:56:00

Modified files:
	.              : WHATS_NEW_DM 
	tools          : dmsetup.c 

Log message:
	Fix return  status 0 for "dmsetup info -c -o help".
	
	Solution returns success for _report_init when help is passed,
	and caller needs to check for _report existance.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.401&r2=1.402
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/dmsetup.c.diff?cvsroot=lvm2&r1=1.142&r2=1.143

--- LVM2/WHATS_NEW_DM	2010/08/03 07:56:03	1.401
+++ LVM2/WHATS_NEW_DM	2010/08/03 12:56:00	1.402
@@ -1,5 +1,6 @@
 Version 1.02.54 - 
 ================================
+  Fix return status 0 for "dmsetup info -c -o help".
   Add check for kernel semaphore support and disable udev_sync if not available.
 
 Version 1.02.53 - 28th July 2010
--- LVM2/tools/dmsetup.c	2010/07/09 15:34:48	1.142
+++ LVM2/tools/dmsetup.c	2010/08/03 12:56:00	1.143
@@ -2652,6 +2652,9 @@
 	r = 1;
 
 out:
+	if (!strcasecmp(options, "help") || !strcmp(options, "?"))
+		r = 1;
+
 	if (len)
 		dm_free(options);
 
@@ -3360,8 +3363,15 @@
 	if (!_switches[COLS_ARG] && !strcmp(c->name, "splitname"))
 		_switches[COLS_ARG]++;
 
-	if (_switches[COLS_ARG] && !_report_init(c))
-		goto out;
+	if (_switches[COLS_ARG]) {
+		if (!_report_init(c))
+			goto out;
+		if (!_report) {
+			if (!strcmp(c->name, "info"))
+				r = 0;  /* info -c -o help */
+			goto out;
+		}
+	}
 
 	#ifdef UDEV_SYNC_SUPPORT
 	if (!_set_up_udev_support(dev_dir))


