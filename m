From: agk@sourceware.org <agk@sourceware.org>
Date: 19 Aug 2011 16:49:01 -0000
Subject: LVM2/libdm/ioctl libdm-iface.c
Message-ID: <20110819164901.20653.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-08-19 16:49:00

Modified files:
	libdm/ioctl    : libdm-iface.c 

Log message:
	revert incomplete inconsistent log message change for now

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.117&r2=1.118

--- LVM2/libdm/ioctl/libdm-iface.c	2011/08/18 19:43:09	1.117
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/08/19 16:49:00	1.118
@@ -1639,10 +1639,9 @@
 				    	    _cmd_data_v4[dmt->type].name,
 					    strerror(errno));
 			else
-				log_error("device-mapper: %s ioctl for %s "
+				log_error("device-mapper: %s ioctl "
 					  "failed: %s",
 					  _cmd_data_v4[dmt->type].name,
-					  dmi->name ? dmi->name : dmi->uuid,
 					  strerror(errno));
 			_dm_zfree_dmi(dmi);
 			return NULL;


