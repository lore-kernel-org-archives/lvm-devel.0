From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 22 Oct 2009 10:40:42 -0000
Subject: LVM2/daemons/dmeventd/plugins/mirror dmeventd_ ...
Message-ID: <20091022104042.13658.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2009-10-22 10:40:41

Modified files:
	daemons/dmeventd/plugins/mirror: dmeventd_mirror.c 

Log message:
	Only announce mirror monitoring to syslog after initialisation succeeds.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c.diff?cvsroot=lvm2&r1=1.26&r2=1.27

--- LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2009/09/17 10:37:24	1.26
+++ LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2009/10/22 10:40:41	1.27
@@ -243,8 +243,6 @@
 
 	pthread_mutex_lock(&_register_mutex);
 
-	syslog(LOG_INFO, "Monitoring mirror device %s for events\n", device);
-
 	/*
 	 * Need some space for allocations.  1024 should be more
 	 * than enough for what we need (device mapper name splitting)
@@ -264,6 +262,8 @@
 		lvm2_run(_lvm_handle, "_memlock_inc");
 	}
 
+	syslog(LOG_INFO, "Monitoring mirror device %s for events\n", device);
+
 	_register_count++;
 	r = 1;
 


