From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 22 Jul 2013 12:04:27 +0000 (UTC)
Subject: master - systemd: lvm2-activation-generator: use LOG_DEBUG/ERR severity for kmsg
Message-ID: <20130722120428.02EAB6126E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ea333a894e93f665a515986fdebf2a6c9e10d42a
Commit:        ea333a894e93f665a515986fdebf2a6c9e10d42a
Parent:        f1d5f6ae81f4723e6aeb2f04bd68cba59cd65403
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jul 22 14:04:12 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jul 22 14:04:12 2013 +0200

systemd: lvm2-activation-generator: use LOG_DEBUG/ERR severity for kmsg

---
 WHATS_NEW                                          |    1 +
 .../lvm2_activation_generator_systemd_red_hat.c    |   35 +++++++++++--------
 2 files changed, 21 insertions(+), 15 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1cce9c9..15419bb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.99 - 
 ===================================
+  Use LOG_DEBUG/ERR msg severity instead default for lvm2-activation-generator.
   Support ARG_GROUPABLE with merge_synonym (for --raidwritemostly).
   Fix segfault when reporting raid_syncaction for older kernels.
   Add LV reporting fields raid_mismatch_count, raid_sync_action, raid_write_behind.
diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
index 5514522..d257479 100644
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
@@ -16,6 +16,7 @@
 #include <unistd.h>
 #include <errno.h>
 #include <stdarg.h>
+#include <syslog.h>
 #include <sys/types.h>
 #include <sys/stat.h>
 #include <fcntl.h>
@@ -31,7 +32,7 @@
 
 static char unit_path[PATH_MAX];
 static char target_path[PATH_MAX];
-static char message[PATH_MAX];
+static char message[PATH_MAX + 3]; /* +3 for '<n>' where n is the log level */
 static int kmsg_fd = -1;
 
 enum {
@@ -46,20 +47,23 @@ static const char *unit_names[] = {
 	[UNIT_NET] = "lvm2-activation-net.service"
 };
 
-__attribute__ ((format(printf, 1, 2)))
-static void kmsg(const char *format, ...)
+__attribute__ ((format(printf, 2, 3)))
+static void kmsg(int log_level, const char *format, ...)
 {
 	va_list ap;
 	int n;
 
+	snprintf(message, 4, "<%d>", log_level);
+
 	va_start(ap, format);
-	n = vsnprintf(message, sizeof(message), format, ap);
+	n = vsnprintf(message + 3, PATH_MAX, format, ap);
 	va_end(ap);
 
-	if (kmsg_fd < 0 || (n < 0 || ((unsigned) n + 1 > sizeof(message))))
+	if (kmsg_fd < 0 || (n < 0 || ((unsigned) n + 1 > PATH_MAX)))
 		return;
 
-	(void) write(kmsg_fd, message, n + 1);
+	/* The n+4: +3 for "<n>" prefix and +1 for '\0' suffix */
+	(void) write(kmsg_fd, message, n + 4);
 }
 
 static int lvm_uses_lvmetad(void)
@@ -68,7 +72,7 @@ static int lvm_uses_lvmetad(void)
 	int r;
 
 	if (!(lvm = lvm_init(NULL))) {
-		kmsg("LVM: Failed to initialize library context for activation generator.\n");
+		kmsg(LOG_ERR, "LVM: Failed to initialize library context for activation generator.\n");
 		return 0;
 	}
 	r = lvm_config_find_bool(lvm, LVM_CONF_USE_LVMETAD, 0);
@@ -86,7 +90,7 @@ static int register_unit_with_target(const char *dir, const char *unit, const ch
 	}
 	(void) dm_prepare_selinux_context(target_path, S_IFDIR);
 	if (mkdir(target_path, 0755) < 0 && errno != EEXIST) {
-		kmsg("LVM: Failed to create target directory %s: %m.\n", target_path);
+		kmsg(LOG_ERR, "LVM: Failed to create target directory %s: %m.\n", target_path);
 		r = 0; goto out;
 	}
 
@@ -95,7 +99,7 @@ static int register_unit_with_target(const char *dir, const char *unit, const ch
 	}
 	(void) dm_prepare_selinux_context(target_path, S_IFLNK);
 	if (symlink(unit_path, target_path) < 0) {
-		kmsg("LVM: Failed to create symlink for unit %s: %m.\n", unit);
+		kmsg(LOG_ERR, "LVM: Failed to create symlink for unit %s: %m.\n", unit);
 		r = 0;
 	}
 out:
@@ -113,7 +117,7 @@ static int generate_unit(const char *dir, int unit)
 		return 0;
 
 	if (!(f = fopen(unit_path, "wxe"))) {
-		kmsg("LVM: Failed to create unit file %s: %m.\n", unit_name);
+		kmsg(LOG_ERR, "LVM: Failed to create unit file %s: %m.\n", unit_name);
 		return 0;
 	}
 
@@ -148,12 +152,12 @@ static int generate_unit(const char *dir, int unit)
 	      "Type=oneshot\n", f);
 
 	if (fclose(f) < 0) {
-		kmsg("LVM: Failed to write unit file %s: %m.\n", unit_name);
+		kmsg(LOG_ERR, "LVM: Failed to write unit file %s: %m.\n", unit_name);
 		return 0;
 	}
 
 	if (!register_unit_with_target(dir, unit_name, target_name)) {
-		kmsg("LVM: Failed to register unit %s with target %s.\n", unit_name, target_name);
+		kmsg(LOG_ERR, "LVM: Failed to register unit %s with target %s.\n", unit_name, target_name);
 		return 0;
 	}
 
@@ -168,13 +172,13 @@ int main(int argc, char *argv[])
 	kmsg_fd = open(KMSG_DEV_PATH, O_WRONLY|O_NOCTTY);
 
 	if (argc > 1 && argc != 4) {
-		kmsg("LVM: Activation generator takes three or no arguments.\n");
+		kmsg(LOG_ERR, "LVM: Activation generator takes three or no arguments.\n");
 		r = EXIT_FAILURE; goto out;
 	}
 
 	/* If lvmetad used, rely on autoactivation instead of direct activation. */
 	if (lvm_uses_lvmetad()) {
-		kmsg("LVM: Logical Volume autoactivation enabled.\n");
+		kmsg(LOG_DEBUG, "LVM: Logical Volume autoactivation enabled.\n");
 		goto out;
 	}
 
@@ -185,7 +189,8 @@ int main(int argc, char *argv[])
 	    !generate_unit(dir, UNIT_NET))
 		r = EXIT_FAILURE;
 out:
-	kmsg("LVM: Activation generator %s.\n", r ? "failed" : "successfully completed");
+	kmsg(r ? LOG_ERR : LOG_DEBUG, "LVM: Activation generator %s.\n",
+	     r ? "failed" : "successfully completed");
 	if (kmsg_fd != -1)
 		(void) close(kmsg_fd);
 	return r;


