From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 28 Aug 2013 14:08:59 +0000 (UTC)
Subject: master - systemd: lvm2-activation-generator: remove default dir if args not specified and require all args to be given
Message-ID: <20130828140859.2878D61150@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0acd7173d14195aeb724c1048a8cbf64a2fd2aa7
Commit:        0acd7173d14195aeb724c1048a8cbf64a2fd2aa7
Parent:        c9258e7f2eebd4fd188d95bcfb9a280d857d186f
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Aug 28 16:06:51 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Aug 28 16:06:51 2013 +0200

systemd: lvm2-activation-generator: remove default dir if args not specified and require all args to be given

Remove default "/tmp" as destination directory if no args
specified for lvm2-activation-generator. Require all the
args to be specified directly for proper functionality.
---
 WHATS_NEW                                          |    1 +
 .../lvm2_activation_generator_systemd_red_hat.c    |    7 +++----
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 29af78d..d974b0a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.101 - 
 ===================================
+  Require exactly 3 arguments for lvm2-activation-generator, remove defaults.
   Disable pvmove of merging or converting logical volumes.
   Enable pvmove of snapshots and snapshot origins.
   Fix inability to specify LV name when pvmove'ing a RAID, mirror, or thin-LV.
diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
index 9cec0a9..7e93d7d 100644
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
@@ -27,7 +27,6 @@
 #define KMSG_DEV_PATH        "/dev/kmsg"
 #define LVM_CONF_USE_LVMETAD "global/use_lvmetad"
 
-#define DEFAULT_UNIT_DIR      "/tmp"
 #define UNIT_TARGET_LOCAL_FS  "local-fs.target"
 #define UNIT_TARGET_REMOTE_FS "remote-fs.target"
 
@@ -174,8 +173,8 @@ int main(int argc, char *argv[])
 
 	kmsg_fd = open(KMSG_DEV_PATH, O_WRONLY|O_NOCTTY);
 
-	if (argc > 1 && argc != 4) {
-		kmsg(LOG_ERR, "LVM: Activation generator takes three or no arguments.\n");
+	if (argc != 4) {
+		kmsg(LOG_ERR, "LVM: Incorrect number of arguments for activation generator.\n");
 		r = EXIT_FAILURE; goto out;
 	}
 
@@ -183,7 +182,7 @@ int main(int argc, char *argv[])
 	if (lvm_uses_lvmetad())
 		goto out;
 
-	dir = argc > 1 ? argv[1] : DEFAULT_UNIT_DIR;
+	dir = argv[1];
 
 	if (!generate_unit(dir, UNIT_EARLY) ||
 	    !generate_unit(dir, UNIT_MAIN) ||


