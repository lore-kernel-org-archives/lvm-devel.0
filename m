From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 13 Sep 2011 13:57:03 -0000
Subject: LVM2/scripts gdbinit
Message-ID: <20110913135703.4342.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-09-13 13:57:02

Modified files:
	scripts        : gdbinit 

Log message:
	reorder some status flag printing in gdbinit file.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/gdbinit.diff?cvsroot=lvm2&r1=1.9&r2=1.10

--- LVM2/scripts/gdbinit	2011/09/08 22:19:45	1.9
+++ LVM2/scripts/gdbinit	2011/09/13 13:57:02	1.10
@@ -189,6 +189,21 @@
 		set $_s_status = $_s_status & ~0x0000000400000000LU
 		printf " RAID_IMAGE"
 	end
+#	if ($_s_status & MIRRORED)
+	if ($_s_status & 0x00008000U)
+		set $_s_status = $_s_status & ~0x00008000U
+		printf " MIRRORED"
+	end
+#	if ($_s_status & MIRROR_LOG)
+	if ($_s_status & 0x00020000U)
+		set $_s_status = $_s_status & ~0x00020000U
+		printf " MIRROR_LOG"
+	end
+#	if ($_s_status & MIRROR_IMAGE)
+	if ($_s_status & 0x00040000U)
+		set $_s_status = $_s_status & ~0x00040000U
+		printf " MIRROR_IMAGE"
+	end
 #	if ($_s_status & VISIBLE_LV)
 	if ($_s_status & 0x00000040U)
 		printf " VISIBLE_LV"
@@ -226,21 +241,6 @@
 		set $_s_status = $_s_status & ~0x00004000U
 		printf " LOCKED"
 	end
-#	if ($_s_status & MIRRORED)
-	if ($_s_status & 0x00008000U)
-		set $_s_status = $_s_status & ~0x00008000U
-		printf " MIRRORED"
-	end
-#	if ($_s_status & MIRROR_LOG)
-	if ($_s_status & 0x00020000U)
-		set $_s_status = $_s_status & ~0x00020000U
-		printf " MIRROR_LOG"
-	end
-#	if ($_s_status & MIRROR_IMAGE)
-	if ($_s_status & 0x00040000U)
-		set $_s_status = $_s_status & ~0x00040000U
-		printf " MIRROR_IMAGE"
-	end
 #	if ($_s_status & LV_NOTSYNCED)
 	if ($_s_status & 0x00080000U)
 		set $_s_status = $_s_status & ~0x00080000U


