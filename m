From: jbrassow@sourceware.org <jbrassow@sourceware.org>
Date: 11 Mar 2011 18:22:39 -0000
Subject: LVM2/scripts gdbinit
Message-ID: <20110311182239.15024.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	jbrassow at sourceware.org	2011-03-11 18:22:39

Modified files:
	scripts        : gdbinit 

Log message:
	detect RAID* LV and segment flags.

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/scripts/gdbinit.diff?cvsroot=lvm2&r1=1.1&r2=1.2

--- LVM2/scripts/gdbinit	2011/03/10 13:45:12	1.1
+++ LVM2/scripts/gdbinit	2011/03/11 18:22:39	1.2
@@ -28,7 +28,7 @@
 printf "\n\n"
 printf "Popular breakpoints:\n"
 printf "break lv_extend\n"
-printf "run -m1 -L 200M -n lv vg\n"
+printf "run --type raid1 -L 200M -n lv vg\n"
 printf "lv_status_r lv\n"
 printf "\n\n"
 
@@ -126,9 +126,21 @@
 	if ($arg0->status & 0x00040000U)
 		printf " MIRROR_IMAGE"
 	end
-#	if ($arg0->status & MIRROR_NOTSYNCED)
+#	if ($arg0->status & RAID)
+	if ($arg0->status & 0x00000001U)
+		printf " RAID"
+	end
+#	if ($arg0->status & RAID_META)
+	if ($arg0->status & 0x00000002U)
+		printf " RAID_META"
+	end
+#	if ($arg0->status & RAID_IMAGE)
+	if ($arg0->status & 0x00000004U)
+		printf " RAID_IMAGE"
+	end
+#	if ($arg0->status & LV_NOTSYNCED)
 	if ($arg0->status & 0x00080000U)
-		printf " MIRROR_NOTSYNCED"
+		printf " LV_NOTSYNCED"
 	end
 #	if ($arg0->status & CONVERTING)
 	if ($arg0->status & 0x00400000U)
@@ -178,8 +190,8 @@
 	if ($_s == $_seg_list_head)
 		printf "[ No segments for %s ]\n", $_lv->name
 	else
+		set $_seg = (struct lv_segment *)$_s
 		while ($_s != $_seg_list_head)
-			set $_seg = (struct lv_segment *)$_s
 			printf "%s[ %s->seg(%d)->status:", $arg1, $_lv->name, $_i
 			__status $_seg
 			printf " ]\n"
@@ -203,10 +215,11 @@
 printf " ]\n"
 end
 				end
-				set $_j = $_j + 1
+				set $_j++
 			end
 			set $_s = $_s->n
-			set $_i = $_i + 1
+			set $_seg = (struct lv_segment *)$_s
+			set $_i++
 		end
 	end
 	printf "\n"	


