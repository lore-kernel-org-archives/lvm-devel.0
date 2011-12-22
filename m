From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 22 Dec 2011 15:55:24 -0000
Subject: LVM2 ./WHATS_NEW daemons/dmeventd/plugins/lvm2 ...
Message-ID: <20111222155524.11358.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-12-22 15:55:21

Modified files:
	.              : WHATS_NEW 
	daemons/dmeventd/plugins/lvm2: .exported_symbols dmeventd_lvm.c 
	                               dmeventd_lvm.h 

Log message:
	Add helper function dmeventd_lvm2_command().
	
	Since this code is in all plugins - create a common helper function.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2214&r2=1.2215
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/lvm2/.exported_symbols.diff?cvsroot=lvm2&r1=1.2&r2=1.3
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.h.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/WHATS_NEW	2011/12/22 15:50:38	1.2214
+++ LVM2/WHATS_NEW	2011/12/22 15:55:21	1.2215
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Add helper dmeventd_lvm2_command() into libdevmapper-event-lvm2 library.
   Updated documentation for dmeventd.
   Drop extra stat call before opening device.
   Reduce number of lstat calls when selecting device alias.
--- LVM2/daemons/dmeventd/plugins/lvm2/.exported_symbols	2010/01/22 12:38:16	1.2
+++ LVM2/daemons/dmeventd/plugins/lvm2/.exported_symbols	2011/12/22 15:55:21	1.3
@@ -4,3 +4,4 @@
 dmeventd_lvm2_unlock
 dmeventd_lvm2_pool
 dmeventd_lvm2_run
+dmeventd_lvm2_command
--- LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c	2011/10/19 08:46:26	1.6
+++ LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c	2011/12/22 15:55:21	1.7
@@ -151,3 +151,26 @@
 	return lvm2_run(_lvm_handle, cmdline);
 }
 
+int dmeventd_lvm2_command(struct dm_pool *mem, char *buffer, size_t size,
+			  const char *cmd, const char *device)
+{
+	char *vg = NULL, *lv = NULL, *layer;
+	int r;
+
+	if (!dm_split_lvm_name(mem, device, &vg, &lv, &layer)) {
+		syslog(LOG_ERR, "Unable to determine VG name from %s.\n",
+		       device);
+		return 0;
+	}
+
+	r = dm_snprintf(buffer, size, "%s %s/%s", cmd, vg, lv);
+
+	dm_pool_free(mem, vg);
+
+	if (r < 0) {
+		syslog(LOG_ERR, "Unable to form LVM command. (too long).\n");
+		return 0;
+	}
+
+	return 1;
+}
--- LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.h	2010/01/21 22:15:46	1.1
+++ LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.h	2011/12/22 15:55:21	1.2
@@ -36,4 +36,7 @@
 
 struct dm_pool *dmeventd_lvm2_pool(void);
 
+int dmeventd_lvm2_command(struct dm_pool *mem, char *buffer, size_t size,
+			  const char *cmd, const char *device);
+
 #endif /* _DMEVENTD_LVMWRAP_H */


