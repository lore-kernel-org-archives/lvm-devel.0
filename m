From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 26 Oct 2009 21:38:36 -0000
Subject: LVM2 libdm/libdm-common.c udev/13-dm-disk.rules
Message-ID: <20091026213836.21205.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2009-10-26 21:38:36

Modified files:
	libdm          : libdm-common.c 
	udev           : 13-dm-disk.rules 

Log message:
	Cleanup of previous commit with latest changes in udev support code.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/libdm-common.c.diff?cvsroot=lvm2&r1=1.88&r2=1.89
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/udev/13-dm-disk.rules.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/libdm/libdm-common.c	2009/10/26 14:29:34	1.88
+++ LVM2/libdm/libdm-common.c	2009/10/26 21:38:35	1.89
@@ -1158,7 +1158,8 @@
 		goto bad;
 	}
 
-	dmt->event_nr = (0x0000FFFF & *cookie) | (flags << 16);
+	dmt->event_nr = (~DM_UDEV_FLAGS_MASK & *cookie) |
+			(flags << DM_UDEV_FLAGS_SHIFT);
 	dmt->cookie_set = 1;
 
 	log_debug("Udev cookie 0x%" PRIx32 " (semid %d) assigned to dm_task "
--- LVM2/udev/13-dm-disk.rules	2009/10/26 14:29:34	1.2
+++ LVM2/udev/13-dm-disk.rules	2009/10/26 21:38:35	1.3
@@ -6,7 +6,7 @@
 # suspended.
 
 # "add" event is processed on coldplug only!
-ACTION!="add|change", GOTO="dm_end"
+ACTION!="add|change", GOTO="dm_other"
 ENV{DM_UDEV_RULES_VSN}!="?*", GOTO="dm_other"
 ENV{DM_UDEV_DISABLE_DISK_RULES_FLAG}=="1", GOTO="dm_other"
 


