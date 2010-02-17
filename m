From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 17 Feb 2010 11:57:08 -0600
Subject: [PATCH 9 of 13] LVM: add mirrored log type
Message-ID: <201002171757.o1HHv8Un004980@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-add-mirrored-log-type.patch

Now it is trivial to add the 'mirrored' mirror log.

Signed-off-by: Jonathan Brassow <jbrassow@redhat.com>

Index: LVM2/tools/commands.h
===================================================================
--- LVM2.orig/tools/commands.h
+++ LVM2/tools/commands.h
@@ -96,7 +96,7 @@ xx(lvconvert,
    "Change logical volume layout",
    0,
    "lvconvert "
-   "[-m|--mirrors Mirrors [{--mirrorlog {disk|core}|--corelog}]]\n"
+   "[-m|--mirrors Mirrors [{--mirrorlog {disk|core|mirrored}|--corelog}]]\n"
    "\t[--repair [--use-policies]]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
    "\t[--alloc AllocationPolicy]\n"
@@ -154,7 +154,7 @@ xx(lvcreate,
    "\t{-l|--extents LogicalExtentsNumber[%{VG|PVS|FREE}] |\n"
    "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
-   "\t[-m|--mirrors Mirrors [--nosync] [{--mirrorlog {disk|core}|--corelog}]]\n"
+   "\t[-m|--mirrors Mirrors [--nosync] [{--mirrorlog {disk|core|mirrored}|--corelog}]]\n"
    "\t[-n|--name LogicalVolumeName]\n"
    "\t[--noudevsync]\n"
    "\t[-p|--permission {r|rw}]\n"
Index: LVM2/tools/lvconvert.c
===================================================================
--- LVM2.orig/tools/lvconvert.c
+++ LVM2/tools/lvconvert.c
@@ -875,7 +875,9 @@ static int _lvconvert_mirrors(struct cmd
 			return 0;
 		}
 
-		if (!strcmp("disk", mirrorlog))
+		if (!strcmp("mirrored", mirrorlog))
+			log_count = 2;
+		else if (!strcmp("disk", mirrorlog))
 			log_count = 1;
 		else if (!strcmp("core", mirrorlog))
 			log_count = 0;
Index: LVM2/tools/lvcreate.c
===================================================================
--- LVM2.orig/tools/lvcreate.c
+++ LVM2/tools/lvcreate.c
@@ -337,12 +337,14 @@ static int _read_mirror_params(struct lv
 	mirrorlog = arg_str_value(cmd, mirrorlog_ARG,
 				  corelog ? "core" : DEFAULT_MIRRORLOG);
 
-	if (!strcmp("disk", mirrorlog)) {
-		if (corelog) {
-			log_error("--mirrorlog disk and --corelog "
-				  "are incompatible");
-			return 0;
-		}
+	if (strcmp("core", mirrorlog) && corelog) {
+		log_error("Please use only one of --mirrorlog or --corelog");
+		return 0;
+	}
+
+	if (!strcmp("mirrored", mirrorlog)) {
+		lp->log_count = 2;
+	} else if (!strcmp("disk", mirrorlog)) {
 		lp->log_count = 1;
 	} else if (!strcmp("core", mirrorlog))
 		lp->log_count = 0;


