From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 11 May 2010 08:32:23 -0000
Subject: LVM2/daemons/dmeventd/plugins mirror/dmeventd_ ...
Message-ID: <20100511083223.32427.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2010-05-11 08:32:23

Modified files:
	daemons/dmeventd/plugins/mirror: dmeventd_mirror.c 
	daemons/dmeventd/plugins/snapshot: dmeventd_snapshot.c 

Log message:
	Headerfile <pthread.h> is no longer needed here

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c.diff?cvsroot=lvm2&r1=1.33&r2=1.34
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2010/03/30 14:39:55	1.33
+++ LVM2/daemons/dmeventd/plugins/mirror/dmeventd_mirror.c	2010/05/11 08:32:22	1.34
@@ -19,8 +19,6 @@
 #include "libdevmapper-event.h"
 #include "dmeventd_lvm.h"
 
-#include <pthread.h>
-
 #include <syslog.h> /* FIXME Replace syslog with multilog */
 /* FIXME Missing openlog? */
 /* FIXME Replace most syslogs with log_error() style messages and add complete context. */
--- LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2010/02/15 12:55:20	1.8
+++ LVM2/daemons/dmeventd/plugins/snapshot/dmeventd_snapshot.c	2010/05/11 08:32:22	1.9
@@ -1,5 +1,5 @@
 /*
- * Copyright (C) 2007-2008 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2007-2010 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -21,7 +21,6 @@
 
 #include "lvm-string.h"
 
-#include <pthread.h>
 #include <syslog.h> /* FIXME Replace syslog with multilog */
 /* FIXME Missing openlog? */
 


