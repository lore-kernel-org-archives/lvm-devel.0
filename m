From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  6 Jun 2014 12:03:52 +0000 (UTC)
Subject: dev-prajnoha-report-select - report: select: add --select arg to pvdisplay, vgdisplay and lvdisplay
Message-ID: <20140606120352.3093960E2F@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a683ffa0db34b832a9411880cd1791944a08e1a1
Commit:        a683ffa0db34b832a9411880cd1791944a08e1a1
Parent:        d8c54252606a72f6477414ca1c610720cbad0920
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 29 09:39:11 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jun 6 11:11:20 2014 +0200

report: select: add --select arg to pvdisplay, vgdisplay and lvdisplay

---
 tools/commands.h  |   11 +++++++----
 tools/lvdisplay.c |    1 +
 tools/pvdisplay.c |    1 +
 tools/vgdisplay.c |    1 +
 4 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index f8eece9..4504126 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -371,6 +371,7 @@ xx(lvdisplay,
    "\t[--nosuffix]\n"
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
+   "\t[-S|--select Selection]\n"
    "\t[-P|--partial] " "\n"
    "\t[--readonly]\n"
    "\t[--segments]\n"
@@ -384,7 +385,7 @@ xx(lvdisplay,
     aligned_ARG, all_ARG, colon_ARG, columns_ARG, ignorelockingfailure_ARG, 
     ignoreskippedcluster_ARG, maps_ARG, noheadings_ARG, nosuffix_ARG,
     options_ARG, sort_ARG, partial_ARG, readonly_ARG, segments_ARG,
-    separator_ARG, unbuffered_ARG, units_ARG)
+    select_ARG, separator_ARG, unbuffered_ARG, units_ARG)
 
 xx(lvextend,
    "Add space to a logical volume",
@@ -743,6 +744,7 @@ xx(pvdisplay,
    "\t[--nosuffix]\n"
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
+   "\t[-S|--select Selection]\n"
    "\t[--readonly]\n"
    "\t[--separator Separator]\n"
    "\t[--unbuffered]\n"
@@ -753,7 +755,7 @@ xx(pvdisplay,
 
    aligned_ARG, all_ARG, colon_ARG, columns_ARG, ignorelockingfailure_ARG,
    ignoreskippedcluster_ARG, maps_ARG, noheadings_ARG, nosuffix_ARG,
-   options_ARG, readonly_ARG, separator_ARG, short_ARG, sort_ARG,
+   options_ARG, readonly_ARG, select_ARG, separator_ARG, short_ARG, sort_ARG,
    unbuffered_ARG, units_ARG)
 
 xx(pvmove,
@@ -1034,6 +1036,7 @@ xx(vgdisplay,
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial] " "\n"
+   "\t[-S|--select Selection]\n"
    "\t[--readonly]\n"
    "\t[--separator Separator]\n"
    "\t[--unbuffered]\n"
@@ -1044,8 +1047,8 @@ xx(vgdisplay,
 
    activevolumegroups_ARG, aligned_ARG, colon_ARG, columns_ARG,
    ignorelockingfailure_ARG, ignoreskippedcluster_ARG, noheadings_ARG,
-   nosuffix_ARG, options_ARG, partial_ARG, readonly_ARG, short_ARG,
-   separator_ARG, sort_ARG, unbuffered_ARG, units_ARG)
+   nosuffix_ARG, options_ARG, partial_ARG, readonly_ARG, select_ARG,
+   short_ARG, separator_ARG, sort_ARG, unbuffered_ARG, units_ARG)
 
 xx(vgexport,
    "Unregister volume group(s) from the system",
diff --git a/tools/lvdisplay.c b/tools/lvdisplay.c
index 1f40f09..185e539 100644
--- a/tools/lvdisplay.c
+++ b/tools/lvdisplay.c
@@ -45,6 +45,7 @@ int lvdisplay(struct cmd_context *cmd, int argc, char **argv)
 	if (arg_count(cmd, aligned_ARG) ||
 	    arg_count(cmd, noheadings_ARG) ||
 	    arg_count(cmd, options_ARG) ||
+	    arg_count(cmd, select_ARG) ||
 	    arg_count(cmd, separator_ARG) ||
 	    arg_count(cmd, sort_ARG) ||
 	    arg_count(cmd, unbuffered_ARG)) {
diff --git a/tools/pvdisplay.c b/tools/pvdisplay.c
index 3de7969..773d9a9 100644
--- a/tools/pvdisplay.c
+++ b/tools/pvdisplay.c
@@ -104,6 +104,7 @@ int pvdisplay(struct cmd_context *cmd, int argc, char **argv)
 	    arg_count(cmd, all_ARG) ||
 	    arg_count(cmd, noheadings_ARG) ||
 	    arg_count(cmd, options_ARG) ||
+	    arg_count(cmd, select_ARG) ||
 	    arg_count(cmd, separator_ARG) ||
 	    arg_count(cmd, sort_ARG) ||
 	    arg_count(cmd, unbuffered_ARG)) {
diff --git a/tools/vgdisplay.c b/tools/vgdisplay.c
index 81ffbd9..a739d11 100644
--- a/tools/vgdisplay.c
+++ b/tools/vgdisplay.c
@@ -65,6 +65,7 @@ int vgdisplay(struct cmd_context *cmd, int argc, char **argv)
 	} else if (arg_count(cmd, aligned_ARG) ||
 		   arg_count(cmd, noheadings_ARG) ||
 		   arg_count(cmd, options_ARG) ||
+		   arg_count(cmd, select_ARG) ||
 		   arg_count(cmd, separator_ARG) ||
 		   arg_count(cmd, sort_ARG) || arg_count(cmd, unbuffered_ARG)) {
 		log_error("Incompatible options selected");


