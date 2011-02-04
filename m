From: agk@sourceware.org <agk@sourceware.org>
Date: 4 Feb 2011 21:26:33 -0000
Subject: LVM2/libdm/ioctl libdm-iface.c
Message-ID: <20110204212633.19151.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-02-04 21:26:33

Modified files:
	libdm/ioctl    : libdm-iface.c 

Log message:
	Warn if secure data flag requested but not supported by kernel.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.91&r2=1.92

--- LVM2/libdm/ioctl/libdm-iface.c	2011/02/04 19:33:53	1.91
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/02/04 21:26:33	1.92
@@ -1541,8 +1541,12 @@
 		dmi->flags |= DM_READONLY_FLAG;
 	if (dmt->skip_lockfs)
 		dmi->flags |= DM_SKIP_LOCKFS_FLAG;
-	if (dmt->secure_data)
+	if (dmt->secure_data) {
+		if (_dm_version_minor < 20)
+			log_warn("WARNING: Secure data flag unsupported by "
+				 "kernel.  Buffers will not be wiped after use.");
 		dmi->flags |= DM_SECURE_DATA_FLAG;
+	}
 	if (dmt->query_inactive_table) {
 		if (_dm_version_minor < 16)
 			log_warn("WARNING: Inactive table query unsupported "


