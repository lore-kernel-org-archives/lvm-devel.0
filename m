From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 30 Mar 2014 21:45:53 +0000 (UTC)
Subject: master - vgimport/vgexport: return invalid cmd
Message-ID: <20140330214553.DE325602D1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cf29de5de0a39ade491e18c1fe0e8bd3c2937b08
Commit:        cf29de5de0a39ade491e18c1fe0e8bd3c2937b08
Parent:        5aa2e5ec8c8fcb279362c73983f09b4b50f706c0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 30 22:38:51 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Mar 30 23:40:27 2014 +0200

vgimport/vgexport: return invalid cmd

When option parsing fails, return invalid cmd instead of fail.
---
 WHATS_NEW        |    1 +
 tools/vgexport.c |    4 ++--
 tools/vgimport.c |    4 ++--
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 626a5b8..dc0d1b4 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Return proper invalid cmd when vgimport/exports find error in parameters.
   Obtain list of known VGs for pvchange --all when using lvmetad.
   Add man page for lvm dumpconfig.
   Drop unused cmd pointer for internal function for_each_sub_lv().
diff --git a/tools/vgexport.c b/tools/vgexport.c
index c573619..ad658f8 100644
--- a/tools/vgexport.c
+++ b/tools/vgexport.c
@@ -56,12 +56,12 @@ int vgexport(struct cmd_context *cmd, int argc, char **argv)
 {
 	if (!argc && !arg_count(cmd, all_ARG)) {
 		log_error("Please supply volume groups or use -a for all.");
-		return ECMD_FAILED;
+		return EINVALID_CMD_LINE;
 	}
 
 	if (argc && arg_count(cmd, all_ARG)) {
 		log_error("No arguments permitted when using -a for all.");
-		return ECMD_FAILED;
+		return EINVALID_CMD_LINE;
 	}
 
 	return process_each_vg(cmd, argc, argv, READ_FOR_UPDATE, NULL,
diff --git a/tools/vgimport.c b/tools/vgimport.c
index 3a0798a..7cb9337 100644
--- a/tools/vgimport.c
+++ b/tools/vgimport.c
@@ -60,12 +60,12 @@ int vgimport(struct cmd_context *cmd, int argc, char **argv)
 {
 	if (!argc && !arg_count(cmd, all_ARG)) {
 		log_error("Please supply volume groups or use -a for all.");
-		return ECMD_FAILED;
+		return EINVALID_CMD_LINE;
 	}
 
 	if (argc && arg_count(cmd, all_ARG)) {
 		log_error("No arguments permitted when using -a for all.");
-		return ECMD_FAILED;
+		return EINVALID_CMD_LINE;
 	}
 
 	if (arg_count(cmd, force_ARG)) {


