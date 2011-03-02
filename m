From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 2 Mar 2011 08:40:29 -0000
Subject: LVM2/libdm libdm-common.c
Message-ID: <20110302084029.32253.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-02 08:40:28

Modified files:
	libdm          : libdm-common.c 

Log message:
	Add missing return

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.111&r2=1.112

--- LVM2/libdm/libdm-common.c	2011/03/02 00:29:57	1.111
+++ LVM2/libdm/libdm-common.c	2011/03/02 08:40:28	1.112
@@ -1427,6 +1427,8 @@
 	int r = _udev_wait(cookie);
 
 	update_devs();
+
+	return r;
 }
 
 #endif		/* UDEV_SYNC_SUPPORT */


