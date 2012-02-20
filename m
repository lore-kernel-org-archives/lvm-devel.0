From: agk@sourceware.org <agk@sourceware.org>
Date: 20 Feb 2012 21:11:08 -0000
Subject: LVM2 WHATS_NEW WHATS_NEW_DM VERSION VERSION_DM
Message-ID: <20120220211108.32614.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-02-20 21:11:06

Modified files:
	.              : WHATS_NEW WHATS_NEW_DM VERSION VERSION_DM 

Log message:
	post-release

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2296&r2=1.2297
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW_DM.diff?cvsroot=lvm2&r1=1.569&r2=1.570
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION.diff?cvsroot=lvm2&r1=1.293&r2=1.294
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/VERSION_DM.diff?cvsroot=lvm2&r1=1.98&r2=1.99

--- LVM2/WHATS_NEW	2012/02/20 19:38:19	1.2296
+++ LVM2/WHATS_NEW	2012/02/20 21:11:06	1.2297
@@ -1,3 +1,6 @@
+Version 2.02.93 - 
+====================================
+
 Version 2.02.92 - 20th February 2012
 ====================================
   Read dmeventd monitoring config settings for every lvm command.
--- LVM2/WHATS_NEW_DM	2012/02/20 19:38:19	1.569
+++ LVM2/WHATS_NEW_DM	2012/02/20 21:11:06	1.570
@@ -1,3 +1,6 @@
+Version 1.02.72 - 
+====================================
+
 Version 1.02.71 - 20th February 2012
 ====================================
   Switch to using built-in blkid in 13-dm-disk.rules.
@@ -5,7 +8,7 @@
   Detect failing fifo and skip 20s retry communication period.
   Add DM_DEFAULT_NAME_MANGLING_MODE environment variable as an override.
   Add dm_lib_init to automatically initialise device-mapper library on load.
-  Replace any '\' char with '\\' in table specification on input.
+  Replace any '\' char with '\\' in dm table specification on input.
   Add mangle command to dmsetup to provide renaming to correct mangled form.
   Add 'mangled_name' and 'unmangled_name' fields to dmsetup info -c -o.
   Add --manglename option to dmsetup to select the name mangling mode.
--- LVM2/VERSION	2012/02/20 19:38:19	1.293
+++ LVM2/VERSION	2012/02/20 21:11:06	1.294
@@ -1 +1 @@
-2.02.92(2)-cvs (2012-02-20)
+2.02.93(2)-cvs (2012-02-20)
--- LVM2/VERSION_DM	2012/02/20 19:38:19	1.98
+++ LVM2/VERSION_DM	2012/02/20 21:11:06	1.99
@@ -1 +1 @@
-1.02.71-cvs (2012-02-20)
+1.02.72-cvs (2012-02-20)


