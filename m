From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 17 Jul 2013 14:55:25 +0000 (UTC)
Subject: master - systemd: generator: add lvm2-activation-net.service
Message-ID: <20130717145525.9958E60EE1@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=8606bf316a683ebd14bb4cdf4eb1b3477a790b62
Commit:        8606bf316a683ebd14bb4cdf4eb1b3477a790b62
Parent:        73e7f6c45ffecc78b1ea4165596355479fb59fe2
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 17 16:21:18 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jul 17 16:54:52 2013 +0200

systemd: generator: add lvm2-activation-net.service

The new lvm2-activation-net.service activates LVM volumes
after network-attached devices are set up (iSCSI and FCoE)
if lvmetad is disabled and hence the autoactivation is not
used.
---
 WHATS_NEW                                          |    1 +
 .../lvm2_activation_generator_systemd_red_hat.c    |   60 +++++++++++++-------
 2 files changed, 41 insertions(+), 20 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 5763bdf..ae725bb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Add lvm2-activation-net systemd unit to activate LVs on net-attached storage.
   Release memory allocated with _cached_info().
   Add whole log_lv and metadata_lv sub volumes when creating partial tree.
   Properly use snapshot layer for origin which is also thin volume.
diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
index f3a01a2..5514522 100644
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
@@ -25,16 +25,27 @@
 #define KMSG_DEV_PATH        "/dev/kmsg"
 #define LVM_CONF_USE_LVMETAD "global/use_lvmetad"
 
-#define DEFAULT_UNIT_DIR     "/tmp"
-#define UNIT_NAME_EARLY      "lvm2-activation-early.service"
-#define UNIT_NAME            "lvm2-activation.service"
-#define UNIT_TARGET          "local-fs.target"
+#define DEFAULT_UNIT_DIR      "/tmp"
+#define UNIT_TARGET_LOCAL_FS  "local-fs.target"
+#define UNIT_TARGET_REMOTE_FS "remote-fs.target"
 
 static char unit_path[PATH_MAX];
 static char target_path[PATH_MAX];
 static char message[PATH_MAX];
 static int kmsg_fd = -1;
 
+enum {
+	UNIT_EARLY,
+	UNIT_MAIN,
+	UNIT_NET
+};
+
+static const char *unit_names[] = {
+	[UNIT_EARLY] = "lvm2-activation-early.service",
+	[UNIT_MAIN] = "lvm2-activation.service",
+	[UNIT_NET] = "lvm2-activation-net.service"
+};
+
 __attribute__ ((format(printf, 1, 2)))
 static void kmsg(const char *format, ...)
 {
@@ -92,16 +103,17 @@ out:
 	return r;
 }
 
-static int generate_unit(const char *dir, int early)
+static int generate_unit(const char *dir, int unit)
 {
 	FILE *f;
-	const char *unit = early ? UNIT_NAME_EARLY : UNIT_NAME;
+	const char *unit_name = unit_names[unit];
+	const char *target_name = unit == UNIT_NET ? UNIT_TARGET_REMOTE_FS : UNIT_TARGET_LOCAL_FS;
 
-	if (dm_snprintf(unit_path, PATH_MAX, "%s/%s", dir, unit) < 0)
+	if (dm_snprintf(unit_path, PATH_MAX, "%s/%s", dir, unit_name) < 0)
 		return 0;
 
 	if (!(f = fopen(unit_path, "wxe"))) {
-		kmsg("LVM: Failed to create unit file %s: %m.\n", unit);
+		kmsg("LVM: Failed to create unit file %s: %m.\n", unit_name);
 		return 0;
 	}
 
@@ -117,25 +129,31 @@ static int generate_unit(const char *dir, int early)
 	      "SourcePath=/etc/lvm/lvm.conf\n"
 	      "DefaultDependencies=no\n", f);
 
-	if (early) {
-		fputs("After=systemd-udev-settle.service\n", f);
-		fputs("Before=cryptsetup.target\n", f);
-	} else
-		fputs("After=lvm2-activation-early.service cryptsetup.target\n", f);
+	if (unit == UNIT_NET) {
+		fputs("After=iscsi.service fcoe.service\n"
+		      "Before=remote-fs.target shutdown.target\n", f);
+	} else {
+		if (unit == UNIT_EARLY) {
+			fputs("After=systemd-udev-settle.service\n", f);
+			fputs("Before=cryptsetup.target\n", f);
+		} else
+			fputs("After=lvm2-activation-early.service cryptsetup.target\n", f);
+
+		fputs("Before=local-fs.target shutdown.target\n"
+		      "Wants=systemd-udev-settle.service\n\n", f);
+	}
 
-	fputs("Before=local-fs.target shutdown.target\n"
-	      "Wants=systemd-udev-settle.service\n\n"
-	      "[Service]\n"
+	fputs("[Service]\n"
 	      "ExecStart=/usr/sbin/lvm vgchange -aay --sysinit\n"
 	      "Type=oneshot\n", f);
 
 	if (fclose(f) < 0) {
-		kmsg("LVM: Failed to write unit file %s: %m.\n", unit);
+		kmsg("LVM: Failed to write unit file %s: %m.\n", unit_name);
 		return 0;
 	}
 
-	if (!register_unit_with_target(dir, unit, UNIT_TARGET)) {
-		kmsg("LVM: Failed to register unit %s with target %s.\n", unit, UNIT_TARGET);
+	if (!register_unit_with_target(dir, unit_name, target_name)) {
+		kmsg("LVM: Failed to register unit %s with target %s.\n", unit_name, target_name);
 		return 0;
 	}
 
@@ -162,7 +180,9 @@ int main(int argc, char *argv[])
 
 	dir = argc > 1 ? argv[1] : DEFAULT_UNIT_DIR;
 
-	if (!generate_unit(dir, 1) || !generate_unit(dir, 0))
+	if (!generate_unit(dir, UNIT_EARLY) ||
+	    !generate_unit(dir, UNIT_MAIN) ||
+	    !generate_unit(dir, UNIT_NET))
 		r = EXIT_FAILURE;
 out:
 	kmsg("LVM: Activation generator %s.\n", r ? "failed" : "successfully completed");


