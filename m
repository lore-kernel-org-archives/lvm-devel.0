From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  9 May 2014 06:57:04 +0000 (UTC)
Subject: dev-prajnoha-selout - selout: add --select arg to pvdisplay, vgdisplay and lvdisplay
Message-ID: <20140509065704.B7F7A60DED@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f97385a31e1ded0e4a198fc40ddb9e40da383445
Commit:        f97385a31e1ded0e4a198fc40ddb9e40da383445
Parent:        74fd20e12dde65ef9c0c5c4b7bee883fc376e481
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Apr 30 11:02:50 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri May 9 08:51:00 2014 +0200

selout: add --select arg to pvdisplay, vgdisplay and lvdisplay

---
 tools/commands.h  |   11 +++++++----
 tools/lvdisplay.c |    1 +
 tools/pvdisplay.c |    1 +
 tools/vgdisplay.c |    1 +
 4 files changed, 10 insertions(+), 4 deletions(-)

diff --git a/tools/commands.h b/tools/commands.h
index 9bbc124..aa55855 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -352,6 +352,7 @@ xx(lvdisplay,
    "\t[--nosuffix]\n"
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
+   "\t[-S|--select Selection]\n"
    "\t[-P|--partial] " "\n"
    "\t[--readonly]\n"
    "\t[--segments]\n"
@@ -365,7 +366,7 @@ xx(lvdisplay,
     aligned_ARG, all_ARG, colon_ARG, columns_ARG, ignorelockingfailure_ARG, 
     ignoreskippedcluster_ARG, maps_ARG, noheadings_ARG, nosuffix_ARG,
     options_ARG, sort_ARG, partial_ARG, readonly_ARG, segments_ARG,
-    separator_ARG, unbuffered_ARG, units_ARG)
+    select_ARG, separator_ARG, unbuffered_ARG, units_ARG)
 
 xx(lvextend,
    "Add space to a logical volume",
@@ -706,6 +707,7 @@ xx(pvdisplay,
    "\t[--nosuffix]\n"
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
+   "\t[-S|--select Selection]\n"
    "\t[--readonly]\n"
    "\t[--separator Separator]\n"
    "\t[--unbuffered]\n"
@@ -716,7 +718,7 @@ xx(pvdisplay,
 
    aligned_ARG, all_ARG, colon_ARG, columns_ARG, ignorelockingfailure_ARG,
    ignoreskippedcluster_ARG, maps_ARG, noheadings_ARG, nosuffix_ARG,
-   options_ARG, readonly_ARG, separator_ARG, short_ARG, sort_ARG,
+   options_ARG, readonly_ARG, select_ARG, separator_ARG, short_ARG, sort_ARG,
    unbuffered_ARG, units_ARG)
 
 xx(pvmove,
@@ -985,6 +987,7 @@ xx(vgdisplay,
    "\t[-o|--options [+]Field[,Field]]\n"
    "\t[-O|--sort [+|-]key1[,[+|-]key2[,...]]]\n"
    "\t[-P|--partial] " "\n"
+   "\t[-S|--select Selection]\n"
    "\t[--readonly]\n"
    "\t[--separator Separator]\n"
    "\t[--unbuffered]\n"
@@ -995,8 +998,8 @@ xx(vgdisplay,
 
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


