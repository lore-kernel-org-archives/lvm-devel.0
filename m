From: mornfall@sourceware.org <mornfall@sourceware.org>
Date: 15 Feb 2012 14:15:52 -0000
Subject: LVM2/daemons/lvmetad lvmetad-core.c
Message-ID: <20120215141552.25519.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mornfall at sourceware.org	2012-02-15 14:15:51

Modified files:
	daemons/lvmetad: lvmetad-core.c 

Log message:
	(lvmetad) Remove unused variable.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/daemons/lvmetad/lvmetad-core.c.diff?cvsroot=lvm2&r1=1.34&r2=1.35

--- LVM2/daemons/lvmetad/lvmetad-core.c	2012/02/15 14:06:48	1.34
+++ LVM2/daemons/lvmetad/lvmetad-core.c	2012/02/15 14:15:50	1.35
@@ -283,7 +283,7 @@
 
 static response pv_list(lvmetad_state *s, request r)
 {
-	struct dm_config_node *cn = NULL, *cn_pvs, *cn_last = NULL;
+	struct dm_config_node *cn = NULL, *cn_pvs;
 	response res = { .buffer = NULL };
 	res.cft = dm_config_create();
 


