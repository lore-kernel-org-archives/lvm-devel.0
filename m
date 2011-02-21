From: snitzer@sourceware.org <snitzer@sourceware.org>
Date: 21 Feb 2011 16:26:25 -0000
Subject: LVM2 ./WHATS_NEW_DM libdm/ioctl/libdm-iface.c
Message-ID: <20110221162625.11989.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	snitzer at sourceware.org	2011-02-21 16:26:25

Modified files:
	.              : WHATS_NEW_DM 
	libdm/ioctl    : libdm-iface.c 

Log message:
	Add inactive table query support for kernel driver >= 4.11.6 (RHEL 5.7).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.448&r2=1.449
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.93&r2=1.94

--- LVM2/WHATS_NEW_DM	2011/02/18 16:13:56	1.448
+++ LVM2/WHATS_NEW_DM	2011/02/21 16:26:23	1.449
@@ -1,5 +1,6 @@
 Version 1.02.64 - 
 ===================================
+  Add inactive table query support for kernel driver >= 4.11.6 (RHEL 5.7).
   Log debug open_count in _node_has_closed_parents().
   Change dm_report_field_string() API to accept const char *const *data.
 
--- LVM2/libdm/ioctl/libdm-iface.c	2011/02/18 23:09:56	1.93
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/02/21 16:26:24	1.94
@@ -992,6 +992,23 @@
 	        _dm_version_minor >= 15);
 }
 
+static int dm_inactive_supported(void)
+{
+	int inactive_supported = 0;
+
+	if (dm_check_version() && _dm_version >= 4) {
+		if (_dm_version_minor >= 16)
+			inactive_supported = 1; /* upstream */
+		else if (_dm_version_minor == 11 &&
+			 (_dm_version_patchlevel >= 6 &&
+			  _dm_version_patchlevel <= 40)) {
+			inactive_supported = 1; /* RHEL 5.7 */
+		}
+	}
+
+	return inactive_supported;
+}
+
 void *dm_get_next_target(struct dm_task *dmt, void *next,
 			 uint64_t *start, uint64_t *length,
 			 char **target_type, char **params)
@@ -1548,7 +1565,7 @@
 		dmi->flags |= DM_SECURE_DATA_FLAG;
 	}
 	if (dmt->query_inactive_table) {
-		if (_dm_version_minor < 16)
+		if (!dm_inactive_supported())
 			log_warn("WARNING: Inactive table query unsupported "
 				 "by kernel.  It will use live table.");
 		dmi->flags |= DM_QUERY_INACTIVE_TABLE_FLAG;


