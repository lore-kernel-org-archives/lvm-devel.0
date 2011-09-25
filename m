From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 25 Sep 2011 19:37:01 -0000
Subject: LVM2 ./WHATS_NEW daemons/clvmd/clvmd-cman.c da ...
Message-ID: <20110925193701.15704.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-09-25 19:37:01

Modified files:
	.              : WHATS_NEW 
	daemons/clvmd  : clvmd-cman.c clvmd-command.c clvmd-comms.h 
	                 clvmd-corosync.c clvmd-openais.c 
	                 clvmd-singlenode.c 
Added files:
	test           : t-clvmd-restart.sh 

Log message:
	Restart CLVMD with same cluster manager
	
	Add named cluster_ops to easily learn the name of the active cluster manager,
	so we are able to restart singlenode manager in testing.
	
	Add simple test for clvmd -S  (restart) and -R (refresh)
	(though it needs some extensions).

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/WHATS_NEW.diff?cvsroot=lvm2&r1=1.2138&r2=1.2139
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-cman.c.diff?cvsroot=lvm2&r1=1.29&r2=1.30
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-command.c.diff?cvsroot=lvm2&r1=1.59&r2=1.60
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-comms.h.diff?cvsroot=lvm2&r1=1.13&r2=1.14
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-corosync.c.diff?cvsroot=lvm2&r1=1.15&r2=1.16
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-openais.c.diff?cvsroot=lvm2&r1=1.17&r2=1.18
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/clvmd/clvmd-singlenode.c.diff?cvsroot=lvm2&r1=1.11&r2=1.12
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/test/t-clvmd-restart.sh.diff?cvsroot=lvm2&r1=NONE&r2=1.1

--- LVM2/WHATS_NEW	2011/09/24 21:19:30	1.2138
+++ LVM2/WHATS_NEW	2011/09/25 19:37:00	1.2139
@@ -1,5 +1,6 @@
 Version 2.02.89 - 
 ==================================
+  Restart CLVMD with same cluster manager.
   Fix log_error() usage in raid and unknown segtype initialisation.
   Improve testing Makefile.
   Fix install_ocf make target when srcdir != builddir. (2.02.80)
--- LVM2/daemons/clvmd/clvmd-cman.c	2011/01/19 23:09:31	1.29
+++ LVM2/daemons/clvmd/clvmd-cman.c	2011/09/25 19:37:00	1.30
@@ -479,6 +479,7 @@
 }
 
 static struct cluster_ops _cluster_cman_ops = {
+	.name                     = "cman",
 	.cluster_init_completed   = _cluster_init_completed,
 	.cluster_send_message     = _cluster_send_message,
 	.name_from_csid           = _name_from_csid,
--- LVM2/daemons/clvmd/clvmd-command.c	2011/09/24 20:50:36	1.59
+++ LVM2/daemons/clvmd/clvmd-command.c	2011/09/25 19:37:00	1.60
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -381,7 +381,7 @@
 	} while (hn);
 
 	/* clvmd + locks (-E uuid) + debug (-d X) + NULL */
-	if (!(argv = malloc((max_locks * 2 + 4) * sizeof(*argv))))
+	if (!(argv = malloc((max_locks * 2 + 5) * sizeof(*argv))))
 		goto_out;
 
 	/*
@@ -396,10 +396,8 @@
 		argv[argc++] = debug_arg;
 	}
 
-	/*
-	 * FIXME: specify used cluster backend
-	 * argv[argc++] = strdup("-Isinglenode");
-	 */
+	argv[argc++] = "-I";
+	argv[argc++] = clops->name;
 
 	/* Now add the exclusively-open LVs */
 	hn = NULL;
--- LVM2/daemons/clvmd/clvmd-comms.h	2011/08/09 18:11:00	1.13
+++ LVM2/daemons/clvmd/clvmd-comms.h	2011/09/25 19:37:00	1.14
@@ -1,6 +1,6 @@
 /*
  * Copyright (C) 2002-2004 Sistina Software, Inc. All rights reserved.
- * Copyright (C) 2004-2009 Red Hat, Inc. All rights reserved.
+ * Copyright (C) 2004-2011 Red Hat, Inc. All rights reserved.
  *
  * This file is part of LVM2.
  *
@@ -23,6 +23,7 @@
 struct local_client;
 
 struct cluster_ops {
+	const char *name;
 	void (*cluster_init_completed) (void);
 
 	int (*cluster_send_message) (const void *buf, int msglen,
--- LVM2/daemons/clvmd/clvmd-corosync.c	2011/01/19 23:09:31	1.15
+++ LVM2/daemons/clvmd/clvmd-corosync.c	2011/09/25 19:37:00	1.16
@@ -598,6 +598,7 @@
 }
 
 static struct cluster_ops _cluster_corosync_ops = {
+	.name                     = "corosync",
 	.cluster_init_completed   = NULL,
 	.cluster_send_message     = _cluster_send_message,
 	.name_from_csid           = _name_from_csid,
--- LVM2/daemons/clvmd/clvmd-openais.c	2011/03/13 18:08:26	1.17
+++ LVM2/daemons/clvmd/clvmd-openais.c	2011/09/25 19:37:00	1.18
@@ -667,6 +667,7 @@
 }
 
 static struct cluster_ops _cluster_openais_ops = {
+	.name                     = "openais",
 	.cluster_init_completed   = NULL,
 	.cluster_send_message     = _cluster_send_message,
 	.name_from_csid           = _name_from_csid,
--- LVM2/daemons/clvmd/clvmd-singlenode.c	2011/08/04 12:13:51	1.11
+++ LVM2/daemons/clvmd/clvmd-singlenode.c	2011/09/25 19:37:00	1.12
@@ -267,6 +267,7 @@
 }
 
 static struct cluster_ops _cluster_singlenode_ops = {
+	.name                     = "singlenode",
 	.cluster_init_completed   = NULL,
 	.cluster_send_message     = _cluster_send_message,
 	.name_from_csid           = _name_from_csid,
/cvs/lvm2/LVM2/test/t-clvmd-restart.sh,v  -->  standard output
revision 1.1
--- LVM2/test/t-clvmd-restart.sh
+++ -	2011-09-25 19:37:01.914932000 +0000
@@ -0,0 +1,44 @@
+#!/bin/sh
+# Copyright (C) 2011 Red Hat, Inc. All rights reserved.
+#
+# This copyrighted material is made available to anyone wishing to use,
+# modify, copy, or redistribute it subject to the terms and conditions
+# of the GNU General Public License v.2.
+#
+# You should have received a copy of the GNU General Public License
+# along with this program; if not, write to the Free Software Foundation,
+# Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+
+export LVM_CLVMD_BINARY="lib/clvmd"
+export LVM_BINARY="lib/lvm"
+
+. lib/test
+
+# only clvmd based test, skip otherwise
+test -e LOCAL_CLVMD || skip
+
+aux prepare_devs 1
+
+vgcreate --clustered y $vg $(cat DEVICES)
+
+lvcreate -an --zero n -n $lv1 -l1 $vg
+lvcreate -an --zero n -n $lv2 -l1 $vg
+lvcreate -l1 $vg
+
+lvchange -aey $vg/$lv1
+lvchange -aey $vg/$lv2
+
+"$LVM_CLVMD_BINARY" -S
+sleep .2
+# restarted clvmd has the same PID (no fork, only execve)
+NEW_LOCAL_CLVMD=$(pgrep clvmd)
+read LOCAL_CLVMD < LOCAL_CLVMD
+test "$LOCAL_CLVMD" -eq "$NEW_LOCAL_CLVMD"
+
+# FIXME: Hmm - how could we test exclusivity is preserved in singlenode ?
+lvchange -an $vg/$lv1
+lvchange -ay $vg/$lv1
+
+lib/clvmd -R
+
+vgremove -ff $vg


