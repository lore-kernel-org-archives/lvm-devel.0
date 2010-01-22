From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 22 Jan 2010 12:48:59 -0000
Subject: LVM2/daemons/dmeventd/plugins mirror/dmeventd_ ...
Message-ID: <20100122124859.17075.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-01-22 12:48:58

Modified files:
	daemons/dmeventd/plugins/mirror: dmeventd_mirror.c 
	daemons/dmeventd/plugins/snapshot: dmeventd_snapshot.c 

Log message:
	Fix syslog prefix in the first message (dmeventd->lvm).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c.diff?cvsroot=lvm2&r1=1.30&r2=1.31
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2010/01/21 22:15:46	1.30
+++ LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2010/01/22 12:48:58	1.31
@@ -225,8 +225,9 @@
 		    int minor __attribute((unused)),
 		    void **unused __attribute((unused)))
 {
+	int r = dmeventd_lvm2_init();
 	syslog(LOG_INFO, "Monitoring mirror device %s for events", device);
-	return dmeventd_lvm2_init();
+	return r;
 }
 
 int unregister_device(const char *device,
--- LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2010/01/22 00:18:37	1.6
+++ LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2010/01/22 12:48:58	1.7
@@ -120,11 +120,12 @@
 		    void **private)
 {
 	int *percent_warning = (int*)private;
+	int r = dmeventd_lvm2_init();
 
 	*percent_warning = WARNING_THRESH; /* Print warning if snapshot is full */
 
 	syslog(LOG_INFO, "Monitoring snapshot %s\n", device);
-	return dmeventd_lvm2_init();
+	return r;
 }
 
 int unregister_device(const char *device,


