From: prajnoha@sourceware.org <prajnoha@sourceware.org>
Date: 13 Dec 2010 10:49:05 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd.c
Message-ID: <20101213104905.31037.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	prajnoha at sourceware.org	2010-12-13 10:49:03

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd.c 

Log message:
	Create /var/run/lvm directory during clvmd initialisation if missing.
	
	We need to be sure that /var/run and /var/lock is always there.
	(E.g. these two directories could be using tmpfs which then loose
	all the content after reboot.)

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.1836&r2=1.1837
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd.c.diff?cvsroot=lvm2&r1=1.87&r2=1.88

--- LVM2/WHATS_NEW	2010/12/13 10:43:56	1.1836
+++ LVM2/WHATS_NEW	2010/12/13 10:49:02	1.1837
@@ -1,5 +1,6 @@
 Version 2.02.79 -  
 ===================================
+  Create /var/run/lvm directory during clvmd initialisation if missing.
   Use new dm_prepare_selinux_context instead of dm_set_selinux_context.
   Avoid revalidating the label cache immediately after scanning.
   Support scanning for a single VG in independent mdas.
--- LVM2/daemons/clvmd/clvmd.c	2010/12/13 10:43:56	1.87
+++ LVM2/daemons/clvmd/clvmd.c	2010/12/13 10:49:03	1.88
@@ -324,6 +324,7 @@
 	int using_gulm = 0;
 	int debug_opt = 0;
 	int clusterwide_opt = 0;
+	mode_t old_mask;
 
 	/* Deal with command-line arguments */
 	opterr = 0;
@@ -413,6 +414,16 @@
 		be_daemon(start_timeout);
 	}
 
+        dm_prepare_selinux_context(DEFAULT_RUN_DIR, S_IFDIR);
+        old_mask = umask(0077);
+        if (dm_create_dir(DEFAULT_RUN_DIR) == 0) {
+                DEBUGLOG("clvmd: unable to create %s directory\n",
+                          DEFAULT_RUN_DIR);
+                umask(old_mask);
+                exit(1);
+        }
+        umask(old_mask);
+
 	/* Create pidfile */
 	(void) dm_prepare_selinux_context(CLVMD_PIDFILE, S_IFREG);
 	if (dm_create_lockfile(CLVMD_PIDFILE) == 0) {


