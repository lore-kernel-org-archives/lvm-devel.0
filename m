From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 9 Jan 2008 15:55:45 -0000
Subject: LVM2 ./WHATS_NEW tools/lvmcmdline.c
Message-ID: <20080109155545.18248.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2008-01-09 15:55:44

Modified files:
	.              : WHATS_NEW 
	tools          : lvmcmdline.c 

Log message:
	Print warning when lvm tools are running as non-root.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.754&r2=1.755
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdline.c.diff?cvsroot=lvm2&r1=1.56&r2=1.57

--- LVM2/WHATS_NEW	2008/01/09 15:32:18	1.754
+++ LVM2/WHATS_NEW	2008/01/09 15:55:44	1.755
@@ -1,5 +1,6 @@
 Version 2.02.30 -
 ===================================
+  Print warning when lvm tools are running as non-root.
   Add snapshot dmeventd library (enables dmeventd snapshot monitoring).
   Prevent pvcreate from overwriting MDA-less PVs belonging to active VGs.
   Fix a segfault if using pvs with --all argument. (2.02.29)
--- LVM2/tools/lvmcmdline.c	2007/11/15 21:59:11	1.56
+++ LVM2/tools/lvmcmdline.c	2008/01/09 15:55:44	1.57
@@ -1140,6 +1140,12 @@
 	log_sys_error("execvp", path);
 }
 
+static void _nonroot_warning()
+{
+	if (getuid() || geteuid())
+		log_warn("WARNING: Running as a non-root user. Functionality may be unavailable.");
+}
+
 int lvm2_main(int argc, char **argv, unsigned is_static)
 {
 	char *base;
@@ -1186,6 +1192,7 @@
 	}
 #ifdef READLINE_SUPPORT
 	if (!alias && argc == 1) {
+		_nonroot_warning();
 		ret = lvm_shell(cmd, &_cmdline);
 		goto out;
 	}
@@ -1203,6 +1210,7 @@
 		argv++;
 	}
 
+	_nonroot_warning();
 	ret = lvm_run_command(cmd, argc, argv);
 	if ((ret == ENO_SUCH_CMD) && (!alias))
 		ret = _run_script(cmd, argc, argv);


