From: agk@sourceware.org <agk@sourceware.org>
Date: 3 Mar 2009 13:03:04 -0000
Subject: LVM2 VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM
Message-ID: <20090303130304.2654.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-03-03 13:03:03

Modified files:
	.              : VERSION VERSION_DM WHATS_NEW WHATS_NEW_DM 

Log message:
	pre-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.191&r2=1.192
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.5&r2=1.6
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1058&r2=1.1059
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.263&r2=1.264

--- LVM2/VERSION	2009/02/27 23:40:11	1.191
+++ LVM2/VERSION	2009/03/03 13:03:03	1.192
@@ -1 +1 @@
-2.02.45-cvs (2009-02-26)
+2.02.45-cvs (2009-03-03)
--- LVM2/VERSION_DM	2009/01/26 14:46:09	1.5
+++ LVM2/VERSION_DM	2009/03/03 13:03:03	1.6
@@ -1 +1 @@
-1.02.31-cvs (2009-01-26)
+1.02.31-cvs (2009-03-03)
--- LVM2/WHATS_NEW	2009/02/28 00:54:06	1.1058
+++ LVM2/WHATS_NEW	2009/03/03 13:03:03	1.1059
@@ -1,15 +1,15 @@
-Version 2.02.45 - 26th February 2009
-====================================
+Version 2.02.45 - 3rd March 2009
+================================
   Attempt proper clean up in child before executing new binary in exec_cmd().
   Do not scan devices if reporting only attributes from PV label.
   Use pkgconfig to obtain corosync library details during configuration.
   Fix error returns in clvmd-corosync interface to DLM.
   Add --refresh to vgchange and vgmknodes man pages.
-  Fixed bug where lvresize option -t was not properly passed to fsadm.
-  Using argv[] list in exec_cmd() to allow more params for external commands.
-  Fsadm does not allow checking mounted filesystem.
-  Fsadm no longer accepts 'any other key' as 'no' answer to y/n.
-  Fsadm improved handling of command line options.
+  Pass --test from lvresize to fsadm as --dry-run.
+  Supply argv[] list to exec_cmd() to allow for variable number of parameters.
+  Prevent fsadm from checking mounted filesystems.
+  No longer treats any other key as 'no' when prompting in fsadm.
+  Tidy fsadm command line processing.
   Add lib/lvm.h and lib/lvm_base.c for the new library interface.
   Move tools/version.h to lib/misc/lvm-version.h.
   Split LVM_VERSION into MAJOR, MINOR, PATCHLEVEL, RELEASE and RELEASE_DATE.
@@ -25,9 +25,9 @@
   Add option to /etc/sysconfig/cluster to select cluster type for clvmd.
   Allow clvmd to start up if its lockspace already exists.
   Separate PV label attributes which do not need parse metadata when reporting.
-  Remove external dependency on the 'cut' command in fsadm.
+  Remove external dependency on the 'cut' command from fsadm.
   Fix pvs segfault when pv mda attributes requested for not available PV.
-  Add support for ext4 resize in fsadm.
+  Add fsadm support for reszing ext4 filesysystems.
   Move locking_type reading inside init_locking().
   Rename get_vgs() to get_vgnames() and clarify related error messages.
   Allow clvmd to be built with all cluster managers & select one on cmdline.
--- LVM2/WHATS_NEW_DM	2009/02/12 20:42:07	1.263
+++ LVM2/WHATS_NEW_DM	2009/03/03 13:03:03	1.264
@@ -1,5 +1,5 @@
-Version 1.02.31 - 
-====================================
+Version 1.02.31 - 3rd March 2009
+================================
   If kernel supports only one dm major number, use in place of any supplied.
 
 Version 1.02.30 - 26th January 2009


