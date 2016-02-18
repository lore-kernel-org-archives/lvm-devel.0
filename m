From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 18 Feb 2016 13:34:03 +0000 (UTC)
Subject: master - metadata: ask for confirmation before really initializing/removing PV that is marked as belonging to a VG
Message-ID: <20160218133403.D12BC60AB6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ecfa465366d2d6f2a995111eef3c8dac3987c2ef
Commit:        ecfa465366d2d6f2a995111eef3c8dac3987c2ef
Parent:        1a141e86238b45ed8c4a2f1f3b8918f40d33f5a9
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Feb 18 14:30:14 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Feb 18 14:33:54 2016 +0100

metadata: ask for confirmation before really initializing/removing PV that is marked as belonging to a VG

Ask for confirmation when using pvcreate/pvremove on a PV which is
marked as belonging to a VG, just like we do in case of a PV which
belongs to known VG:

$ pvcreate -ff /dev/sda
Really INITIALIZE physical volume "/dev/sda" that is marked as belonging to a VG [y/n]? n
  /dev/sda: physical volume not initialized

$ pvremove -ff /dev/sda
Really WIPE LABELS from physical volume "/dev/sda" that is marked as belonging to a VG [y/n]? n
  /dev/sda: physical volume label not removed
---
 lib/metadata/metadata.c    |   23 ++++++++++++++++++-----
 lib/metadata/pv_manip.c    |   44 +++++++++++++++++++++++++-------------------
 test/shell/pv-ext-flags.sh |    8 ++++----
 3 files changed, 47 insertions(+), 28 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index ca7f9c7..8478abb 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -1470,6 +1470,8 @@ int vg_split_mdas(struct cmd_context *cmd __attribute__((unused)),
 static int _pvcreate_check(struct cmd_context *cmd, const char *name,
 			   struct pvcreate_params *pp, int *wiped)
 {
+	static const char really_init_msg[] = "Really INITIALIZE physical volume";
+	static const char not_init_msg[] = "physical volume not initialized";
 	struct physical_volume *pv;
 	struct device *dev;
 	int r = 0;
@@ -1504,11 +1506,22 @@ static int _pvcreate_check(struct cmd_context *cmd, const char *name,
 	}
 
 	/* prompt */
-	if (pv && !is_orphan(pv) && !pp->yes &&
-	    yes_no_prompt("Really INITIALIZE physical volume \"%s\" of volume group \"%s\" [y/n]? ",
-			  name, pv_vg_name(pv)) == 'n') {
-		log_error("%s: physical volume not initialized", name);
-		goto out;
+	if (pv && !pp->yes) {
+		if (is_orphan(pv)) {
+			if (used) {
+				if (yes_no_prompt("%s \"%s\" that is marked as belonging to a VG [y/n]? ",
+						  really_init_msg, name) == 'n') {
+					log_error("%s: %s", name, not_init_msg);
+					goto out;
+				}
+			}
+		} else {
+			if (yes_no_prompt("%s \"%s\" of volume group \"%s\" [y/n]? ",
+					  really_init_msg, name, pv_vg_name(pv)) == 'n') {
+				log_error("%s: %s", name, not_init_msg);
+				goto out;
+			}
+		}
 	}
 
 	if (sigint_caught())
diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index 423b647..8c3a5dd 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -687,9 +687,6 @@ out:
 	return r;
 }
 
-const char _really_wipe[] =
-    "Really WIPE LABELS from physical volume \"%s\" of volume group \"%s\" [y/n]? ";
-
 /*
  * Decide whether it is "safe" to wipe the labels on this device.
  * 0 indicates we may not.
@@ -697,6 +694,8 @@ const char _really_wipe[] =
 static int pvremove_check(struct cmd_context *cmd, const char *name,
 			  unsigned force_count, unsigned prompt, struct dm_list *pvslist)
 {
+	static const char really_wipe_msg[] = "Really WIPE LABELS from physical volume";
+	static const char not_removed_msg[] = "physical volume label not removed";
 	static const char pvremove_force_hint_msg[] = "(If you are certain you need pvremove, then confirm by using --force twice.)";
 	struct device *dev;
 	struct label *label;
@@ -741,25 +740,32 @@ static int pvremove_check(struct cmd_context *cmd, const char *name,
 			log_error("%s", pvremove_force_hint_msg);
 			goto out;
 		}
-
-		r = 1;
-		goto out;
-	}
-
-	/* we must have -ff to overwrite a non orphan */
-	if (force_count < 2) {
-		log_error("PV %s belongs to Volume Group %s so please use vgreduce first.", name, pv_vg_name(pv));
-		log_error("%s", pvremove_force_hint_msg);
-		goto out;
+	} else {
+		/* we must have -ff to overwrite a non orphan */
+		if (force_count < 2) {
+			log_error("PV %s belongs to Volume Group %s so please use vgreduce first.", name, pv_vg_name(pv));
+			log_error("%s", pvremove_force_hint_msg);
+			goto out;
+		}
 	}
 
 	/* prompt */
-	if (!prompt &&
-	    yes_no_prompt("Really WIPE LABELS from physical volume \"%s\" "
-			  "of volume group \"%s\" [y/n]? ",
-			  name, pv_vg_name(pv)) == 'n') {
-		log_error("%s: physical volume label not removed", name);
-		goto out;
+	if (!prompt) {
+		if (is_orphan(pv)) {
+			if (used) {
+				if (yes_no_prompt("%s \"%s\" that is marked as belonging to a VG [y/n]? ",
+						   really_wipe_msg, name) == 'n') {
+					log_error("%s: %s", name, not_removed_msg);
+					goto out;
+				}
+			}
+		} else {
+			if (yes_no_prompt("%s \"%s\" of volume group \"%s\" [y/n]? ",
+					  really_wipe_msg, name, pv_vg_name(pv)) == 'n') {
+				log_error("%s: %s", name, not_removed_msg);
+				goto out;
+			}
+		}
 	}
 
 	if (force_count) {
diff --git a/test/shell/pv-ext-flags.sh b/test/shell/pv-ext-flags.sh
index 072ec2c..5b35aa4 100644
--- a/test/shell/pv-ext-flags.sh
+++ b/test/shell/pv-ext-flags.sh
@@ -55,9 +55,9 @@ grep "$MARKED_AS_USED_MSG" err
 dd if="$dev1" of=dev1_backup bs=1M
 
 # pvcreate and pvremove can be forced even if the PV is marked as used
-pvremove -ff "$dev1"
+pvremove -ff -y "$dev1"
 dd if=dev1_backup of="$dev1" bs=1M
-pvcreate -ff "$dev1"
+pvcreate -ff -y "$dev1"
 dd if=dev1_backup of="$dev1" bs=1M
 
 # prepare a VG with $dev1 and $dev both having 1 MDA
@@ -120,9 +120,9 @@ grep "$MARKED_AS_USED_MSG" err
 dd if="$dev1" of=dev1_backup bs=1M
 
 # pvcreate and pvremove can be forced even if the PV is marked as used
-pvremove -ff "$dev1"
+pvremove -ff -y "$dev1"
 dd if=dev1_backup of="$dev1" bs=1M
-pvcreate -ff "$dev1"
+pvcreate -ff -y "$dev1"
 dd if=dev1_backup of="$dev1" bs=1M
 
 # prepare a VG with $dev1 and $dev both having 1 MDA


