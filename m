From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 27 Mar 2014 12:15:15 +0000 (UTC)
Subject: master - lvrename: fix exit code
Message-ID: <20140327121515.7C8FD6196E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=28e4bf0b6dae2cad6bb996c0c87d41b256f59517
Commit:        28e4bf0b6dae2cad6bb996c0c87d41b256f59517
Parent:        80fe100afa3bb2cbbc81bb4517a762159f0ebe65
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Mar 27 12:24:35 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Mar 27 13:04:55 2014 +0100

lvrename: fix exit code

Return invalid cmd line (3) when error is detect on cmd line input.
Cmd failed (5) is used when command processing fails.
---
 WHATS_NEW        |    1 +
 tools/lvrename.c |   10 ++++++----
 2 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a9289b5..007fb75 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  When lvrename fails on argument parsing return invalid cmd line error (5->3).
   Fix exit code regression in failing pvchange command (2.02.66).
   Include 'lvm dumpconfig --type missing' and '--type diff' output to lvmdump.
   Return failure when specifying negative size for pvresize.
diff --git a/tools/lvrename.c b/tools/lvrename.c
index 5b1f50b..dd66ba4 100644
--- a/tools/lvrename.c
+++ b/tools/lvrename.c
@@ -75,16 +75,18 @@ int lvrename(struct cmd_context *cmd, int argc, char **argv)
 	if (strlen(lv_name_new) > maxlen) {
 		log_error("New logical volume path exceeds maximum length "
 			  "of %" PRIsize_t "!", maxlen);
-		return ECMD_FAILED;
+		return EINVALID_CMD_LINE;
 	}
 
 	if (!*lv_name_new) {
 		log_error("New logical volume name may not be blank");
-		return ECMD_FAILED;
+		return EINVALID_CMD_LINE;
 	}
 
-	if (!apply_lvname_restrictions(lv_name_new))
-		return_ECMD_FAILED;
+	if (!apply_lvname_restrictions(lv_name_new)) {
+		stack;
+		return EINVALID_CMD_LINE;
+	}
 
 	if (!validate_name(lv_name_new)) {
 		log_error("New logical volume name \"%s\" is invalid",


