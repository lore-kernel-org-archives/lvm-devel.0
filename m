From: agk@sourceware.org <agk@sourceware.org>
Date: 23 Sep 2011 17:16:29 -0000
Subject: LVM2/libdm/ioctl libdm-iface.c
Message-ID: <20110923171629.21970.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2011-09-23 17:16:28

Modified files:
	libdm/ioctl    : libdm-iface.c 

Log message:
	explain why we may now retry

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.122&r2=1.123

--- LVM2/libdm/ioctl/libdm-iface.c	2011/09/22 17:59:58	1.122
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/09/23 17:16:28	1.123
@@ -1654,6 +1654,11 @@
 					  _cmd_data_v4[dmt->type].name,
 					  strerror(errno));
 
+			/*
+			 * It's sometimes worth retrying after EBUSY in case
+			 * it's a transient failure caused by an asynchronous
+			 * process quickly scanning the device.
+			 */
 			*retryable = errno == EBUSY;
 
 			_dm_zfree_dmi(dmi);
@@ -1739,6 +1744,12 @@
 repeat_ioctl:
 	if (!(dmi = _do_dm_ioctl(dmt, command, _ioctl_buffer_double_factor,
 				 ioctl_retry, &retryable))) {
+		/*
+		 * Async udev rules that scan devices commonly cause transient
+		 * failures.  Normally you'd expect the user to have made sure
+		 * nothing was using the device before issuing REMOVE, so it's
+		 * worth retrying in case the failure is indeed transient.
+		 */
 		if (retryable && dmt->type == DM_DEVICE_REMOVE &&
 		    dmt->retry_remove && ++ioctl_retry <= DM_IOCTL_RETRIES) {
 			usleep(DM_RETRY_USLEEP_DELAY);


