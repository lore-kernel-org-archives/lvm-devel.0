From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 24 Nov 2009 16:10:27 -0000
Subject: LVM2 ./WHATS_NEW lib/cache/lvmcache.c lib/comm ...
Message-ID: <20091124161027.22448.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2009-11-24 16:10:26

Modified files:
	.              : WHATS_NEW 
	lib/cache      : lvmcache.c 
	lib/commands   : toolcontext.c toolcontext.h 

Log message:
	Refresh device filters before full device rescan in lvmcache.
	
	The sysfs filter initialise hash of available devices using
	scan of /sys/block. We need to refresh even this hash
	when performing full scan otherwise the newly appeared
	device could be rejected, because there is no entry
	in sysfs filter.
	
	This easily could happen when attaching new device
	to cluster node. (Only force refresh of context
	in clvmd -R works here now).
	
	Unfortunately consequences of this are much worse,
	missing device part on that node is replaced with missing segment
	(even when no partial arg is selected) and this directly
	lead to data corruption.
	
	See https://bugzilla.redhat.com/show_bug.cgi?id=538515
	
	Simply fix it by refreshing device filters in lvmcache
	before performing the full device scan.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1323&r2=1.1324
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmcache.c.diff?cvsroot=lvm2&r1=1.71&r2=1.72
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.c.diff?cvsroot=lvm2&r1=1.86&r2=1.87
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/commands/toolcontext.h.diff?cvsroot=lvm2&r1=1.35&r2=1.36

--- LVM2/WHATS_NEW	2009/11/24 16:08:49	1.1323
+++ LVM2/WHATS_NEW	2009/11/24 16:10:25	1.1324
@@ -1,5 +1,6 @@
 Version 2.02.56 - 
 ====================================
+  Refresh device filters before full device rescan in lvmcache.
   Return error status if vgchange fails to activate some volume.
   Fix memory lock imbalance in locking code.
   Revert vg_read_internal change, clvmd cannot use vg_read now. (2.02.55)
--- LVM2/lib/cache/lvmcache.c	2009/10/27 17:00:46	1.71
+++ LVM2/lib/cache/lvmcache.c	2009/11/24 16:10:25	1.72
@@ -510,6 +510,11 @@
 		goto out;
 	}
 
+	if (full_scan == 2 && !refresh_filters(cmd)) {
+		log_error("refresh filters failed");
+		goto out;
+	}
+
 	if (!(iter = dev_iter_create(cmd->filter, (full_scan == 2) ? 1 : 0))) {
 		log_error("dev_iter creation failed");
 		goto out;
--- LVM2/lib/commands/toolcontext.c	2009/10/16 17:41:50	1.86
+++ LVM2/lib/commands/toolcontext.c	2009/11/24 16:10:26	1.87
@@ -1223,6 +1223,16 @@
 	}
 }
 
+int refresh_filters(struct cmd_context *cmd)
+{
+	if (cmd->filter) {
+		cmd->filter->destroy(cmd->filter);
+		cmd->filter = NULL;
+	}
+
+	return _init_filters(cmd, 0);
+}
+
 int refresh_toolcontext(struct cmd_context *cmd)
 {
 	log_verbose("Reloading config files");
--- LVM2/lib/commands/toolcontext.h	2009/10/16 17:41:50	1.35
+++ LVM2/lib/commands/toolcontext.h	2009/11/24 16:10:26	1.36
@@ -105,6 +105,7 @@
 				       const char *system_dir);
 void destroy_toolcontext(struct cmd_context *cmd);
 int refresh_toolcontext(struct cmd_context *cmd);
+int refresh_filters(struct cmd_context *cmd);
 int config_files_changed(struct cmd_context *cmd);
 int init_lvmcache_orphans(struct cmd_context *cmd);
 


