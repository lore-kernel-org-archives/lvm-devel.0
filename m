From: Jonathan Brassow <jbrassow@redhat.com>
Date: Tue, 19 Jan 2010 20:22:47 -0600
Subject: [PATCH 9 of 10] LVM: add redundant log type
Message-ID: <201001200222.o0K2Mlhl024406@hydrogen.msp.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Patch name: lvm-add-redundant-log-type.patch

Now it is trivial to add the 'redundant' mirror log.

RFC: Jonathan Brassow <jbrassow@redhat.com>

Index: LVM2/tools/commands.h
===================================================================
--- LVM2.orig/tools/commands.h
+++ LVM2/tools/commands.h
@@ -96,7 +96,7 @@ xx(lvconvert,
    "Change logical volume layout",
    0,
    "lvconvert "
-   "[-m|--mirrors Mirrors [{--mirrorlog {disk|core}|--corelog}]]\n"
+   "[-m|--mirrors Mirrors [{--mirrorlog {disk|core|redundant}|--corelog}]]\n"
    "\t[--repair [--use-policies]]\n"
    "\t[-R|--regionsize MirrorLogRegionSize]\n"
    "\t[--alloc AllocationPolicy]\n"
@@ -154,7 +154,7 @@ xx(lvcreate,
    "\t{-l|--extents LogicalExtentsNumber |\n"
    "\t -L|--size LogicalVolumeSize[bBsSkKmMgGtTpPeE]}\n"
    "\t[-M|--persistent {y|n}] [--major major] [--minor minor]\n"
-   "\t[-m|--mirrors Mirrors [--nosync] [{--mirrorlog {disk|core}|--corelog}]]\n"
+   "\t[-m|--mirrors Mirrors [--nosync] [{--mirrorlog {disk|core|redundant}|--corelog}]]\n"
    "\t[-n|--name LogicalVolumeName]\n"
    "\t[--noudevsync]\n"
    "\t[-p|--permission {r|rw}]\n"
Index: LVM2/tools/lvconvert.c
===================================================================
--- LVM2.orig/tools/lvconvert.c
+++ LVM2/tools/lvconvert.c
@@ -808,7 +808,9 @@ static int _lvconvert_mirrors(struct cmd
 			return 0;
 		}
 
-		if (!strcmp("disk", mirrorlog))
+		if (!strcmp("redundant", mirrorlog))
+			log_count = 2;
+		else if (!strcmp("disk", mirrorlog))
 			log_count = 1;
 		else if (!strcmp("core", mirrorlog))
 			log_count = 0;
Index: LVM2/tools/lvcreate.c
===================================================================
--- LVM2.orig/tools/lvcreate.c
+++ LVM2/tools/lvcreate.c
@@ -327,12 +327,14 @@ static int _read_mirror_params(struct lv
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
+	if (!strcmp("redundant", mirrorlog)) {
+		lp->log_count = 2;
+	} else if (!strcmp("disk", mirrorlog)) {
 		lp->log_count = 1;
 	} else if (!strcmp("core", mirrorlog))
 		lp->log_count = 0;


