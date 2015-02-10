From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 10 Feb 2015 15:13:16 +0000 (UTC)
Subject: master - tools: allow -S|--select for vgexport and vgimport
Message-ID: <20150210151316.5908C60CFB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=80cca53611d3603c12db08ddc1b25bfd6b874436
Commit:        80cca53611d3603c12db08ddc1b25bfd6b874436
Parent:        b93f586954f05147822128b3bf25f668656d2769
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Dec 12 12:03:34 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Feb 10 16:10:17 2015 +0100

tools: allow -S|--select for vgexport and vgimport

---
 WHATS_NEW        |    1 +
 tools/commands.h |    6 ++++--
 tools/vgexport.c |    6 +++---
 tools/vgimport.c |    6 +++---
 4 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b9566f8..314cfd8 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.117 - 
 ====================================
+  Add support for -S/--select to vgexport and vgimport.
   Add support for -S/--select to vgdisplay, lvdisplay and pvdisplay without -C.
   Add support for -S/--select to vgremove and lvremove.
   Add support for -S/--select to vgchange,lvchange and pvchange.
diff --git a/tools/commands.h b/tools/commands.h
index f8984d1..5221f79 100644
--- a/tools/commands.h
+++ b/tools/commands.h
@@ -1091,11 +1091,12 @@ xx(vgexport,
    "\t[--commandprofile ProfileName]\n"
    "\t[-d|--debug]\n"
    "\t[-h|--help]\n"
+   "\t[-S|--select Selection]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
    "\tVolumeGroupName [VolumeGroupName...]\n",
 
-   all_ARG, test_ARG)
+   all_ARG, select_ARG, test_ARG)
 
 xx(vgextend,
    "Add physical volumes to a volume group",
@@ -1129,12 +1130,13 @@ xx(vgimport,
    "\t[-d|--debug]\n"
    "\t[-f|--force]\n"
    "\t[-h|--help]\n"
+   "\t[-S|--select Selection]\n"
    "\t[-t|--test]\n"
    "\t[-v|--verbose]\n"
    "\t[--version]\n"
    "\tVolumeGroupName...\n",
 
-   all_ARG, force_ARG, test_ARG)
+   all_ARG, force_ARG, select_ARG, test_ARG)
 
 xx(vgmerge,
    "Merge volume groups",
diff --git a/tools/vgexport.c b/tools/vgexport.c
index aeff612..d4be3c7 100644
--- a/tools/vgexport.c
+++ b/tools/vgexport.c
@@ -51,12 +51,12 @@ bad:
 
 int vgexport(struct cmd_context *cmd, int argc, char **argv)
 {
-	if (!argc && !arg_count(cmd, all_ARG)) {
-		log_error("Please supply volume groups or use -a for all.");
+	if (!argc && !arg_count(cmd, all_ARG) && !arg_is_set(cmd, select_ARG)) {
+		log_error("Please supply volume groups or use -S for selection or use -a for all.");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (argc && arg_count(cmd, all_ARG)) {
+	if (arg_count(cmd, all_ARG) && (argc || arg_is_set(cmd, select_ARG))) {
 		log_error("No arguments permitted when using -a for all.");
 		return EINVALID_CMD_LINE;
 	}
diff --git a/tools/vgimport.c b/tools/vgimport.c
index 857f4a9..d5ca7c3 100644
--- a/tools/vgimport.c
+++ b/tools/vgimport.c
@@ -58,12 +58,12 @@ bad:
 
 int vgimport(struct cmd_context *cmd, int argc, char **argv)
 {
-	if (!argc && !arg_count(cmd, all_ARG)) {
-		log_error("Please supply volume groups or use -a for all.");
+	if (!argc && !arg_count(cmd, all_ARG) && !arg_is_set(cmd, select_ARG)) {
+		log_error("Please supply volume groups or -S for selection or use -a for all.");
 		return EINVALID_CMD_LINE;
 	}
 
-	if (argc && arg_count(cmd, all_ARG)) {
+	if (arg_count(cmd, all_ARG) && (argc || arg_is_set(cmd, select_ARG))) {
 		log_error("No arguments permitted when using -a for all.");
 		return EINVALID_CMD_LINE;
 	}


