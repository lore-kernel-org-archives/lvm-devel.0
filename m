From: agk@sourceware.org <agk@sourceware.org>
Date: 28 Feb 2012 18:23:57 -0000
Subject: LVM2/lib/cache lvmetad.c
Message-ID: <20120228182357.23909.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	agk at sourceware.org	2012-02-28 18:23:56

Modified files:
	lib/cache      : lvmetad.c 

Log message:
	Invert some return codes (which used to get ignored anyway) in cases when
	lvmetad is not being used.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/lib/cache/lvmetad.c.diff?cvsroot=lvm2&r1=1.8&r2=1.9

--- LVM2/lib/cache/lvmetad.c	2012/02/28 11:09:06	1.8
+++ LVM2/lib/cache/lvmetad.c	2012/02/28 18:23:56	1.9
@@ -1,3 +1,17 @@
+/*
+ * Copyright (C) 2012 Red Hat, Inc.
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
 #include "lib.h"
 #include "toolcontext.h"
 #include "metadata.h"
@@ -360,7 +374,7 @@
 	struct dm_config_node *cn;
 
 	if (!_using_lvmetad)
-		return_0;
+		return 1;
 
 	reply = daemon_send_simple(_lvmetad, "pv_list", NULL);
 
@@ -388,7 +402,7 @@
 	struct dm_config_node *cn;
 
 	if (!_using_lvmetad)
-		return_0;
+		return 1;
 
 	reply = daemon_send_simple(_lvmetad, "vg_list", NULL);
 	if (reply.error || strcmp(daemon_reply_str(reply, "response", ""), "OK")) {
@@ -678,4 +692,3 @@
 		  "It is strongly recommended that you restart lvmetad immediately.");
 	return 0;
 }
-


