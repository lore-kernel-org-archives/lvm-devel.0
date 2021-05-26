From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 26 May 2021 14:12:31 +0000 (GMT)
Subject: main - vdo: fix preload of kvdo
Message-ID: <20210526141231.050B6385702D@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b725b5ea6ecfeef428fd7ffcd6855a38378d761b
Commit:        b725b5ea6ecfeef428fd7ffcd6855a38378d761b
Parent:        4a746f7ffcc8e61c9cb5ce9f9e8a061d1ef6b28e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 26 00:19:28 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 26 16:12:20 2021 +0200

vdo: fix preload of kvdo

Commit 5bf1dba9eb8a8b77410e386e59dadeb27801b14e broke load of kvdo
kernel module - correct it by loading kvdo instead of trying dm-vdo.
---
 WHATS_NEW               |  1 +
 lib/activate/activate.c | 10 +++-------
 2 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4b5b23072..04c6dcdf2 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.13 - 
 ===============================
+  Fix load of kvdo target when it is not present in memory (2.03.12).
 
 Version 2.03.12 - 07th May 2021
 ===============================
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 71db98191..6bda7385b 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -574,13 +574,9 @@ int module_present(struct cmd_context *cmd, const char *target_name)
 	}
 
 #ifdef MODPROBE_CMD
-	if (strcmp(target_name, MODULE_NAME_VDO) == 0) {
-		argv[1] = target_name;		/* ATM kvdo is without dm- prefix */
-		if ((ret = exec_cmd(cmd, argv, NULL, 0)))
-			return ret;
-	}
-
-	if (dm_snprintf(module, sizeof(module), "dm-%s", target_name) < 0) {
+	if (strcmp(target_name, TARGET_NAME_VDO) == 0)
+		argv[1] = MODULE_NAME_VDO; /* ATM kvdo is without dm- prefix */
+	else if (dm_snprintf(module, sizeof(module), "dm-%s", target_name) < 0) {
 		log_error("module_present module name too long: %s",
 			  target_name);
 		return 0;


