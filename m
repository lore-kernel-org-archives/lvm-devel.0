From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 23 Feb 2012 22:50:50 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/lvm-functions.c
Message-ID: <20120223225050.13671.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2012-02-23 22:50:50

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : lvm-functions.c 

Log message:
	Limit sscanf params with size
	
	Make sure parsed string fits given char buffer.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2308&r2=1.2309
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/lvm-functions.c.diff?cvsroot=lvm2&r1=1.129&r2=1.130

--- LVM2/WHATS_NEW	2012/02/23 22:41:57	1.2308
+++ LVM2/WHATS_NEW	2012/02/23 22:50:50	1.2309
@@ -1,5 +1,6 @@
 Version 2.02.94 - 
 ====================================
+  Limit sscanf parameters with buffer size in clvmd get_initial_state().
   Use const lv pointer for lv_is_active...() functions. 
   Use same signed numbers in _mirrored_transient_status().
   Integrate client-side lvmetad into build.
--- LVM2/daemons/clvmd/lvm-functions.c	2012/01/20 00:27:19	1.129
+++ LVM2/daemons/clvmd/lvm-functions.c	2012/02/23 22:50:50	1.130
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2012 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -729,7 +729,7 @@
 	}
 
 	while (fgets(line, sizeof(line), lvs)) {
-	        if (sscanf(line, "%s %s %s %s\n", vg, lv, flags, vg_flags) == 4) {
+	        if (sscanf(line, "%64s %64s %25s %25s\n", vg, lv, flags, vg_flags) == 4) {
 
 			/* States: s:suspended a:active S:dropped snapshot I:invalid snapshot */
 		        if (strlen(vg) == 38 &&                         /* is is a valid UUID ? */


