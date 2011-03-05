From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 5 Mar 2011 21:17:19 -0000
Subject: LVM2/libdm/ioctl libdm-iface.c
Message-ID: <20110305211719.11626.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2011-03-05 21:17:19

Modified files:
	libdm/ioctl    : libdm-iface.c 

Log message:
	Move secure flag warning to verbose level.
	
	This feature is not yet upstream and becuase cryptsetup in next version
	uses this flag, it will cause a lot of noise on old kernels.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.97&r2=1.98

--- LVM2/libdm/ioctl/libdm-iface.c	2011/03/02 08:41:55	1.97
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/03/05 21:17:19	1.98
@@ -1560,8 +1560,8 @@
 		dmi->flags |= DM_SKIP_LOCKFS_FLAG;
 	if (dmt->secure_data) {
 		if (_dm_version_minor < 20)
-			log_warn("WARNING: Secure data flag unsupported by "
-				 "kernel.  Buffers will not be wiped after use.");
+			log_verbose("Secure data flag unsupported by kernel. "
+				    "Buffers will not be wiped after use.");
 		dmi->flags |= DM_SECURE_DATA_FLAG;
 	}
 	if (dmt->query_inactive_table) {


