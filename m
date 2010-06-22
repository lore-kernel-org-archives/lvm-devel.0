From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 22 Jun 2010 13:11:32 -0000
Subject: LVM2 ./WHATS_NEW libdm/misc/dm-log-userspace.h
Message-ID: <20100622131132.3835.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2010-06-22 13:11:32

Modified files:
	.              : WHATS_NEW 
	libdm/misc     : dm-log-userspace.h 

Log message:
	Use flexible data[] in cmirrord request to prevent abort in runtime size checks.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1623&r2=1.1624
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/misc/dm-log-userspace.h.diff?cvsroot=lvm2&r1=1.2&r2=1.3

--- LVM2/WHATS_NEW	2010/06/21 16:12:33	1.1623
+++ LVM2/WHATS_NEW	2010/06/22 13:11:29	1.1624
@@ -1,5 +1,6 @@
 Version 2.02.68 -
 ===============================
+  Use flexible data[] in cmirrord request to prevent abort in runtime size checks.
   Honor log argument when down-converting stacked mirror.
   Sleep to workaround clvmd -S race: socket closed early and server drops cmd.
   Use early udev synchronisation and update of dev nodes for clustered mirrors.
--- LVM2/libdm/misc/dm-log-userspace.h	2010/01/19 01:10:47	1.2
+++ LVM2/libdm/misc/dm-log-userspace.h	2010/06/22 13:11:32	1.3
@@ -391,7 +391,7 @@
 	uint32_t request_type;  /* DM_ULOG_* defined above */
 	uint32_t data_size;     /* How much data (not including this struct) */
 
-	char data[0];
+	char data[];
 };
 
 #endif /* __DM_LOG_USERSPACE_H__ */


