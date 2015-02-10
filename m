From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 10 Feb 2015 15:13:14 +0000 (UTC)
Subject: master - tools: allow -S|--select for vgdisplay, lvdisplay and pvdisplay without -C
Message-ID: <20150210151314.208DD6110A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b93f586954f05147822128b3bf25f668656d2769
Commit:        b93f586954f05147822128b3bf25f668656d2769
Parent:        00744b053f395be79ab1cb80fdf7342548aa79e2
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Dec 12 10:20:15 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 10 16:09:40 2015 +0100

tools: allow -S|--select for vgdisplay, lvdisplay and pvdisplay without -C

We already allowed -S|--select with {vg,lv,pv}display -C (which
was then equal to {vg,lv,pv}s command. Since we support selection
in toolib now, we can support -S also without using -C in *display
commands now.
---
 WHATS_NEW         |    1 +
 tools/commands.h  |    3 +++
 tools/lvdisplay.c |    1 -
 tools/pvdisplay.c |    1 -
 tools/vgdisplay.c |    1 -
 5 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7fa7d3c..b9566f8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.117 - 
 ====================================
+  Add support for -S/--select to vgdisplay, lvdisplay and pvdisplay without -C.
   Add support for -S/--select to vgremove and lvremove.
   Add support for -S/--select to vgchange,lvchange and pvchange.
   Add infrastructure to support selection for non-reporting tools.
diff --git a/tools/commands.h b/tools/commands.h
index 63dbb2a..f8984d1 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -369,6 +369,7 @@ xx(lvdisplay,
    "\t[--nosuffix]\n"
    "\t[-P|--partial]\n"
    "\t[--readonly]\n"
+   "\t[-S|--select Selection]\n"
    "\t[--units hHbBsSkKmMgGtTpPeE]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
@@ -747,6 +748,7 @@ xx(pvdisplay,
    "\t[-m|--maps]\n"
    "\t[--nosuffix]\n"
    "\t[--readonly]\n"
+   "\t[-S|--select Selection]\n"
    "\t[-s|--short]\n"
    "\t[--units hHbBsSkKmMgGtTpPeE]\n"
    "\t[-v|--verbose]\n"
@@ -1049,6 +1051,7 @@ xx(vgdisplay,
    "\t[--nosuffix]\n"
    "\t[-P|--partial]\n"
    "\t[--readonly]\n"
+   "\t[-S|--select Selection]\n"
    "\t[--units hHbBsSkKmMgGtTpPeE]\n"
    "\t[--version]\n"
    "\t[VolumeGroupName [VolumeGroupName...]]\n"
diff --git a/tools/lvdisplay.c b/tools/lvdisplay.c
index 6b1540f..7d900cc 100644
--- a/tools/lvdisplay.c
+++ b/tools/lvdisplay.c
@@ -46,7 +46,6 @@ int lvdisplay(struct cmd_context *cmd, int argc, char **argv)
 	    arg_count(cmd, binary_ARG) ||
 	    arg_count(cmd, noheadings_ARG) ||
 	    arg_count(cmd, options_ARG) ||
-	    arg_count(cmd, select_ARG) ||
 	    arg_count(cmd, separator_ARG) ||
 	    arg_count(cmd, sort_ARG) ||
 	    arg_count(cmd, unbuffered_ARG)) {
diff --git a/tools/pvdisplay.c b/tools/pvdisplay.c
index 94a3bbf..2763889 100644
--- a/tools/pvdisplay.c
+++ b/tools/pvdisplay.c
@@ -77,7 +77,6 @@ int pvdisplay(struct cmd_context *cmd, int argc, char **argv)
 	    arg_count(cmd, binary_ARG) ||
 	    arg_count(cmd, noheadings_ARG) ||
 	    arg_count(cmd, options_ARG) ||
-	    arg_count(cmd, select_ARG) ||
 	    arg_count(cmd, separator_ARG) ||
 	    arg_count(cmd, sort_ARG) ||
 	    arg_count(cmd, unbuffered_ARG)) {
diff --git a/tools/vgdisplay.c b/tools/vgdisplay.c
index 3c34727..5e5ceda 100644
--- a/tools/vgdisplay.c
+++ b/tools/vgdisplay.c
@@ -66,7 +66,6 @@ int vgdisplay(struct cmd_context *cmd, int argc, char **argv)
 		   arg_count(cmd, binary_ARG) ||
 		   arg_count(cmd, noheadings_ARG) ||
 		   arg_count(cmd, options_ARG) ||
-		   arg_count(cmd, select_ARG) ||
 		   arg_count(cmd, separator_ARG) ||
 		   arg_count(cmd, sort_ARG) || arg_count(cmd, unbuffered_ARG)) {
 		log_error("Incompatible options selected");


