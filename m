From: agk@sourceware.org <agk@sourceware.org>
Date: 15 Sep 2009 12:51:29 -0000
Subject: LVM2/daemons/clvmd clvmd-corosync.c clvmd-gulm ...
Message-ID: <20090915125129.16628.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2009-09-15 12:51:28

Modified files:
	daemons/clvmd  : clvmd-corosync.c clvmd-gulm.c clvmd-openais.c 
	                 refresh_clvmd.c tcp-comms.c 

Log message:
	missing (C) reminders

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-corosync.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-gulm.c.diff?cvsroot=lvm2&r1=1.27&r2=1.28
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-openais.c.diff?cvsroot=lvm2&r1=1.12&r2=1.13
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/refresh_clvmd.c.diff?cvsroot=lvm2&r1=1.6&r2=1.7
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/tcp-comms.c.diff?cvsroot=lvm2&r1=1.19&r2=1.20

--- LVM2/daemons/clvmd/clvmd-corosync.c	2009/08/28 19:22:05	1.11
+++ LVM2/daemons/clvmd/clvmd-corosync.c	2009/09/15 12:51:28	1.12
@@ -1,14 +1,20 @@
-/******************************************************************************
-*******************************************************************************
-**
-**  Copyright (C) 2009 Red Hat, Inc. All rights reserved.
-**
-*******************************************************************************
-******************************************************************************/
+/*
+ * Copyright (C) 2009 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
 
-/* This provides the interface between clvmd and corosync/DLM as the cluster
+/*
+ * This provides the interface between clvmd and corosync/DLM as the cluster
  * and lock manager.
- *
  */
 
 #define _GNU_SOURCE
--- LVM2/daemons/clvmd/clvmd-gulm.c	2009/07/15 20:02:46	1.27
+++ LVM2/daemons/clvmd/clvmd-gulm.c	2009/09/15 12:51:28	1.28
@@ -1,13 +1,20 @@
-/******************************************************************************
-*******************************************************************************
-**
-**  Copyright (C) Sistina Software, Inc.  2002-2003  All rights reserved.
-**  Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
-**
-*******************************************************************************
-******************************************************************************/
+/*
+ * Copyright (C) 2002-2003 Sistina Software, Inc. All rights reserved.
+ * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
 
-/* This provides the interface between clvmd and gulm as the cluster
+/*
+ * This provides the interface between clvmd and gulm as the cluster
  * and lock manager.
  *
  * It also provides the "liblm" functions too as it's hard (and pointless)
@@ -17,7 +24,6 @@
  * on the cluster nodes. That is done in tcp-comms.c
  */
 
-
 #include <pthread.h>
 #include <sys/types.h>
 #include <sys/utsname.h>
--- LVM2/daemons/clvmd/clvmd-openais.c	2009/08/28 19:22:05	1.12
+++ LVM2/daemons/clvmd/clvmd-openais.c	2009/09/15 12:51:28	1.13
@@ -1,14 +1,20 @@
-/******************************************************************************
-*******************************************************************************
-**
-**  Copyright (C) 2007-2009 Red Hat, Inc. All rights reserved.
-**
-*******************************************************************************
-******************************************************************************/
+/*
+ * Copyright (C) 2007-2009 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
 
-/* This provides the interface between clvmd and OpenAIS as the cluster
+/*
+ * This provides the interface between clvmd and OpenAIS as the cluster
  * and lock manager.
- *
  */
 
 #define _GNU_SOURCE
--- LVM2/daemons/clvmd/refresh_clvmd.c	2008/11/04 16:41:47	1.6
+++ LVM2/daemons/clvmd/refresh_clvmd.c	2009/09/15 12:51:28	1.7
@@ -15,7 +15,6 @@
 
 /*
  * Tell all clvmds in a cluster to refresh their toolcontext
- *
  */
 
 #define _GNU_SOURCE
--- LVM2/daemons/clvmd/tcp-comms.c	2008/11/04 16:41:47	1.19
+++ LVM2/daemons/clvmd/tcp-comms.c	2009/09/15 12:51:28	1.20
@@ -1,17 +1,24 @@
-/******************************************************************************
-*******************************************************************************
-**
-**  Copyright (C) Sistina Software, Inc.  2002-2003  All rights reserved.
-**  Copyright (C) 2004-2005 Red Hat, Inc. All rights reserved.
-**
-*******************************************************************************
-******************************************************************************/
-
-/* This provides the inter-clvmd communications for a system without CMAN.
-   There is a listening TCP socket which accepts new connections in the
-   normal way.
-   It can also make outgoing connnections to the other clvmd nodes.
-*/
+/*
+ *  Copyright (C) 2002-2003 Sistina Software, Inc. All rights reserved.
+ *  Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ *
+ * This file is part of LVM2.
+ *
+ * This copyrighted material is made available to anyone wishing to use,
+ * modify, copy, or redistribute it subject to the terms and conditions
+ * of the GNU Lesser General Public License v.2.1.
+ *
+ * You should have received a copy of the GNU Lesser General Public License
+ * along with this program; if not, write to the Free Software Foundation,
+ * Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+
+/*
+ * This provides the inter-clvmd communications for a system without CMAN.
+ * There is a listening TCP socket which accepts new connections in the
+ * normal way.
+ * It can also make outgoing connnections to the other clvmd nodes.
+ */
 
 #define _GNU_SOURCE
 #define _FILE_OFFSET_BITS 64


