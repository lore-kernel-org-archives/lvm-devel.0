From: agk@sourceware.org <agk@sourceware.org>
Date: 20 Mar 2011 02:00:53 -0000
Subject: LVM2/libdm/ioctl libdm-iface.c
Message-ID: <20110320020053.24940.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-03-20 02:00:52

Modified files:
	libdm/ioctl    : libdm-iface.c 

Log message:
	Fix last checkin - added error message text wrong.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.101&r2=1.102

--- LVM2/libdm/ioctl/libdm-iface.c	2011/03/18 13:21:02	1.101
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/03/20 02:00:52	1.102
@@ -965,10 +965,8 @@
 	if (_check_version(dmversion, sizeof(dmversion), _dm_compat))
 		return 1;
 
-	if (!_dm_compat) {
-		log_error("Support for older device-mapped version is disabled.");
-		goto bad;
-	}
+	if (!_dm_compat)
+		goto_bad;
 
 	log_verbose("device-mapper ioctl protocol version %u failed. "
 		    "Trying protocol version 1.", _dm_version);


