From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 19 Oct 2011 08:46:29 -0000
Subject: LVM2 daemons/dmeventd/plugins/lvm2/dmeventd_lv ...
Message-ID: <20111019084629.5998.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2011-10-19 08:46:27

Modified files:
	daemons/dmeventd/plugins/lvm2: dmeventd_lvm.c 
	tools          : lvm2cmd.h lvmcmdlib.c 

Log message:
	Keep the LVM-based dmeventd plugins from trying to manipulate the dmeventd
	monitoring state of the logical volumes they are currently acting on.
	
	Until now, every time a logical volume has been changed by a dmeventd plugin,
	this plugin would have called back to dmeventd through the external FIFO
	mechanism. I am fairly sure this was superfluous, inefficient and possibly even
	dangerous.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvm2cmd.h.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdlib.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13

--- LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c	2010/09/30 11:40:14	1.5
+++ LVM2/daemons/dmeventd/plugins/lvm2/dmeventd_lvm.c	2011/10/19 08:46:26	1.6
@@ -113,6 +113,7 @@
 			_mem_pool = NULL;
 			goto out;
 		}
+		lvm2_disable_dmeventd_monitoring(_lvm_handle);
 		/* FIXME Temporary: move to dmeventd core */
 		lvm2_run(_lvm_handle, "_memlock_inc");
 	}
--- LVM2/tools/lvm2cmd.h	2010/06/16 13:01:25	1.5
+++ LVM2/tools/lvm2cmd.h	2011/10/19 08:46:27	1.6
@@ -52,6 +52,12 @@
 void *lvm2_init(void);
 
 /*
+ * Disable any dmeventd calls that the library may otherwise do. Useful to avoid
+ * recursive calls from dmeventd to itself.
+ */
+void lvm2_disable_dmeventd_monitoring(void *handle);
+
+/*
  * Set log level (as above) if using built-in logging function. 
  * Default is LVM2_LOG_PRINT.  Use LVM2_LOG_SUPPRESS to suppress output.
  */
--- LVM2/tools/lvmcmdlib.c	2010/03/05 14:48:34	1.12
+++ LVM2/tools/lvmcmdlib.c	2011/10/19 08:46:27	1.13
@@ -97,6 +97,10 @@
 	return ret;
 }
 
+void lvm2_disable_dmeventd_monitoring(void *handle) {
+	init_dmeventd_monitor(DMEVENTD_MONITOR_IGNORE);
+}
+
 void lvm2_log_level(void *handle, int level)
 {
 	struct cmd_context *cmd = (struct cmd_context *) handle;


