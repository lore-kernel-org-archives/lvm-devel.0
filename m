From: mbroz@sourceware.org <mbroz@sourceware.org>
Date: 27 Mar 2012 11:43:33 -0000
Subject: LVM2/tools pvmove.c
Message-ID: <20120327114333.10768.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	mbroz at sourceware.org	2012-03-27 11:43:33

Modified files:
	tools          : pvmove.c 

Log message:
	Also skip pvmove for remotely active LVs.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/tools/pvmove.c.diff?cvsroot=lvm2&r1=1.97&r2=1.98

--- LVM2/tools/pvmove.c	2012/03/26 20:33:40	1.97
+++ LVM2/tools/pvmove.c	2012/03/27 11:43:32	1.98
@@ -239,6 +239,14 @@
 			continue;
 		}
 
+		if (vg_is_clustered(vg) &&
+		    lv_is_active_exclusive_remotely(lv)) {
+			lv_skipped = 1;
+			log_print("Skipping LV %s which is activated "
+				  "exclusively on remote node.", lv->name);
+			continue;
+		}
+
 		if (vg_is_clustered(vg)) {
 			if (lv_is_active_exclusive_locally(lv))
 				lv_exclusive_count++;


