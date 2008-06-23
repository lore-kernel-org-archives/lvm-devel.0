From: meyering@sourceware.org <meyering@sourceware.org>
Date: 23 Jun 2008 09:27:45 -0000
Subject: LVM2 ./WHATS_NEW tools/lvmcmdlib.c
Message-ID: <20080623092745.8672.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	meyering at sourceware.org	2008-06-23 09:27:45

Modified files:
	.              : WHATS_NEW 
	tools          : lvmcmdlib.c 

Log message:
	lvm2_run: don't return uninitialized for _memlock_inc or _memlock_dec
	
	* tools/lvmcmdlib.c: Initialize "ret".  Also avoid useless string
	comparison.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.910&r2=1.911
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/lvmcmdlib.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7

--- LVM2/WHATS_NEW	2008/06/23 09:25:07	1.910
+++ LVM2/WHATS_NEW	2008/06/23 09:27:45	1.911
@@ -1,5 +1,6 @@
 Version 2.02.39 -
 ================================
+  lvm2_run: Don't return uninitialized "ret" for _memlock_inc or _memlock_dec.
   Avoid link failure when configuring without --enable-cmdlib.
   Avoid link failure when configuring without --enable-readline.
   Make clvmd return immediately if other nodes are down in an openais cluster.
--- LVM2/tools/lvmcmdlib.c	2008/01/30 14:00:02	1.6
+++ LVM2/tools/lvmcmdlib.c	2008/06/23 09:27:45	1.7
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2001-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2007 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2008 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -79,9 +79,10 @@
 	}
 
 	/* FIXME Temporary - move to libdevmapper */
+	ret = ECMD_PROCESSED;
 	if (!strcmp(cmdline, "_memlock_inc"))
 		memlock_inc();
-	if (!strcmp(cmdline, "_memlock_dec"))
+	else if (!strcmp(cmdline, "_memlock_dec"))
 		memlock_dec();
 	else
 		ret = lvm_run_command(cmd, argc, argv);


