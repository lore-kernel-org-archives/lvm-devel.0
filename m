From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 11 Dec 2014 14:20:28 +0000 (UTC)
Subject: master - tools, man: --binary option is available with -C for {pv, vg, lv}display
Message-ID: <20141211142028.8AB2E60FE7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3b02ccd2011c058f01c3acce76c599f3a39408e7
Commit:        3b02ccd2011c058f01c3acce76c599f3a39408e7
Parent:        3ec482a3797261d867c097963e65c03306f01c97
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Dec 11 15:16:04 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Dec 11 15:20:16 2014 +0100

tools, man: --binary option is available with -C for {pv,vg,lv}display

The {pv,vg,lv}display *do* use reporting in case "-C|--columns" is used.
The man page was correct, the recognition for the --binary was missing
in the code though!
---
 WHATS_NEW         |    1 +
 tools/commands.h  |   23 ++++++++++++++---------
 tools/lvdisplay.c |    1 +
 tools/pvdisplay.c |    1 +
 tools/vgdisplay.c |    1 +
 5 files changed, 18 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5e1b143..4855e1a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.115 -
 =====================================
+  Add missing recognition for --binary option with {pv,vg,lv}display -C.
   Fix vgimportclone to notify lvmetad about changes done if lvmetad is used.
   Fix vgimportclone to properly override config if it is missing in lvm.conf.
   Fix automatic use of configure --enable-udev-systemd-background-jobs.
diff --git a/tools/commands.h b/tools/commands.h
index 8dc335c..8b6b607 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -374,6 +374,7 @@ xx(lvdisplay,
    "lvdisplay --columns|-C\n"
    "\t[--aligned]\n"
    "\t[-a|--all]\n"
+   "\t[--binary]\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
@@ -394,10 +395,11 @@ xx(lvdisplay,
    "\t[--version]\n"
    "\t[LogicalVolume[Path] [LogicalVolume[Path]...]]\n",
 
-    aligned_ARG, all_ARG, colon_ARG, columns_ARG, ignorelockingfailure_ARG,
-    ignoreskippedcluster_ARG, maps_ARG, noheadings_ARG, nosuffix_ARG,
-    options_ARG, sort_ARG, partial_ARG, readonly_ARG, segments_ARG,
-    select_ARG, separator_ARG, unbuffered_ARG, units_ARG)
+    aligned_ARG, all_ARG, binary_ARG, colon_ARG, columns_ARG,
+    ignorelockingfailure_ARG, ignoreskippedcluster_ARG, maps_ARG,
+    noheadings_ARG, nosuffix_ARG, options_ARG, sort_ARG, partial_ARG,
+    readonly_ARG, segments_ARG, select_ARG, separator_ARG,
+    unbuffered_ARG, units_ARG)
 
 xx(lvextend,
    "Add space to a logical volume",
@@ -749,6 +751,7 @@ xx(pvdisplay,
    "pvdisplay --columns|-C\n"
    "\t[--aligned]\n"
    "\t[-a|--all]\n"
+   "\t[--binary]\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
@@ -767,10 +770,11 @@ xx(pvdisplay,
    "\t[--version]\n"
    "\t[PhysicalVolumePath [PhysicalVolumePath...]]\n",
 
-   aligned_ARG, all_ARG, colon_ARG, columns_ARG, ignorelockingfailure_ARG,
-   ignoreskippedcluster_ARG, maps_ARG, noheadings_ARG, nosuffix_ARG,
-   options_ARG, readonly_ARG, select_ARG, separator_ARG, short_ARG, sort_ARG,
-   unbuffered_ARG, units_ARG)
+   aligned_ARG, all_ARG, binary_ARG, colon_ARG, columns_ARG,
+   ignorelockingfailure_ARG, ignoreskippedcluster_ARG, maps_ARG,
+   noheadings_ARG, nosuffix_ARG, options_ARG, readonly_ARG,
+   select_ARG, separator_ARG, short_ARG, sort_ARG, unbuffered_ARG,
+   units_ARG)
 
 xx(pvmove,
    "Move extents from one physical volume to another",
@@ -1045,6 +1049,7 @@ xx(vgdisplay,
    "\n"
    "vgdisplay --columns|-C\n"
    "\t[--aligned]\n"
+   "\t[--binary]\n"
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
@@ -1064,7 +1069,7 @@ xx(vgdisplay,
    "\t[--version]\n"
    "\t[VolumeGroupName [VolumeGroupName...]]\n",
 
-   activevolumegroups_ARG, aligned_ARG, colon_ARG, columns_ARG,
+   activevolumegroups_ARG, aligned_ARG, binary_ARG, colon_ARG, columns_ARG,
    ignorelockingfailure_ARG, ignoreskippedcluster_ARG, noheadings_ARG,
    nosuffix_ARG, options_ARG, partial_ARG, readonly_ARG, select_ARG,
    short_ARG, separator_ARG, sort_ARG, unbuffered_ARG, units_ARG)
diff --git a/tools/lvdisplay.c b/tools/lvdisplay.c
index 185e539..fb3420a 100644
--- a/tools/lvdisplay.c
+++ b/tools/lvdisplay.c
@@ -43,6 +43,7 @@ int lvdisplay(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	if (arg_count(cmd, aligned_ARG) ||
+	    arg_count(cmd, binary_ARG) ||
 	    arg_count(cmd, noheadings_ARG) ||
 	    arg_count(cmd, options_ARG) ||
 	    arg_count(cmd, select_ARG) ||
diff --git a/tools/pvdisplay.c b/tools/pvdisplay.c
index d4cb516..50522d9 100644
--- a/tools/pvdisplay.c
+++ b/tools/pvdisplay.c
@@ -73,6 +73,7 @@ int pvdisplay(struct cmd_context *cmd, int argc, char **argv)
 
 	if (arg_count(cmd, aligned_ARG) ||
 	    arg_count(cmd, all_ARG) ||
+	    arg_count(cmd, binary_ARG) ||
 	    arg_count(cmd, noheadings_ARG) ||
 	    arg_count(cmd, options_ARG) ||
 	    arg_count(cmd, select_ARG) ||
diff --git a/tools/vgdisplay.c b/tools/vgdisplay.c
index 6e068aa..59d741a 100644
--- a/tools/vgdisplay.c
+++ b/tools/vgdisplay.c
@@ -63,6 +63,7 @@ int vgdisplay(struct cmd_context *cmd, int argc, char **argv)
 		}
 		return vgs(cmd, argc, argv);
 	} else if (arg_count(cmd, aligned_ARG) ||
+		   arg_count(cmd, binary_ARG) ||
 		   arg_count(cmd, noheadings_ARG) ||
 		   arg_count(cmd, options_ARG) ||
 		   arg_count(cmd, select_ARG) ||


