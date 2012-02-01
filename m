From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 1 Feb 2012 20:11:59 -0000
Subject: LVM2/daemons/dmeventd/plugins/lvm2 dmeventd_lvm.c
Message-ID: <20120201201159.4713.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-01 20:11:58

Modified files:
	daemons/dmeventd/plugins/lvm2: dmeventd_lvm.c 

Log message:
	Remove a dubious log message ("another thread is handling an event") from LVM
	dmeventd plugins. Fixes RHBZ 771419.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c.diff?cvsroot=lvm2&r1=1.7&r2=1.8

--- LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c	2011/12/22 15:55:21	1.7
+++ LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c	2012/02/01 20:11:58	1.8
@@ -82,10 +82,7 @@
 
 void dmeventd_lvm2_lock(void)
 {
-	if (pthread_mutex_trylock(&_event_mutex)) {
-		syslog(LOG_NOTICE, "Another thread is handling an event. Waiting...");
-		pthread_mutex_lock(&_event_mutex);
-	}
+	pthread_mutex_lock(&_event_mutex);
 }
 
 void dmeventd_lvm2_unlock(void)


