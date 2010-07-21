From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 21 Jul 2010 15:21:25 -0000
Subject: LVM2/lib/mirror mirrored.c
Message-ID: <20100721152125.8173.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2010-07-21 15:21:25

Modified files:
	lib/mirror     : mirrored.c 

Log message:
	Building without the '--enable-cmirrord' option means that
	CMIRRORD_PIDFILE is not defined.  This makes the build fail.
	Therefore, we need to conditionalize the check for cmirrord
	based on if CMIRRORD_PIDFILE is defined.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/mirror/mirrored.c.diff?cvsroot=lvm2&r1=1.73&r2=1.74

--- LVM2/lib/mirror/mirrored.c	2010/07/21 13:40:22	1.73
+++ LVM2/lib/mirror/mirrored.c	2010/07/21 15:21:24	1.74
@@ -528,10 +528,15 @@
                          * otherwise, the kernel module will fail to make
                          * contact.
                          */
+#ifdef CMIRRORD_PIDFILE
                         if (!dm_daemon_is_running(CMIRRORD_PIDFILE)) {
                                 log_verbose("Cluster mirror log daemon is not running");
                                 _mirror_attributes &= ~MIRROR_LOG_CLUSTERED;
                         }
+#else
+			log_verbose("Cluster mirror log daemon not included in build");
+			_mirror_attributes &= ~MIRROR_LOG_CLUSTERED;
+#endif
 		}
 		*attributes = _mirror_attributes;
 	}


