From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Thu, 30 Aug 2018 07:16:17 -0400
Subject: master - scripts: lvm2-activation-generator: add prefix for all kmsg messages
Message-ID: <201808301116.w7UBGHEP012928@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3d5c4847b663c42573ffabba7f26f30196f54d82
Commit:        3d5c4847b663c42573ffabba7f26f30196f54d82
Parent:        cb17ef221bdefea3625a22c19c6d8f5504441771
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Aug 30 12:46:41 2018 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Aug 30 13:14:10 2018 +0200

scripts: lvm2-activation-generator: add prefix for all kmsg messages

Add "lvm2-activation-generator: " prefix for all kmsg messages written by
lvm2-activation-generator so we can identify the message in global system log.
---
 WHATS_NEW                                          |    1 +
 .../lvm2_activation_generator_systemd_red_hat.c    |   24 ++++++++++----------
 2 files changed, 13 insertions(+), 12 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8489252..6003f0a 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 3.0.0
 =============
+  Add 'lvm2-activation-generator:' prefix for kmsg messages logged by generator.
   Add After=rbdmap.service to {lvm2-activation-net,blk-availability}.service.
   Reduce max concurrent aios to avoid EMFILE with many devices.
   Fix lvconvert conversion attempts to linear.
diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
index b751841..5dc39ae 100644
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
@@ -57,19 +57,19 @@ static void _error(const char *format, ...)
 {
 	int n;
 	va_list ap;
-	char message[PATH_MAX + 3];	/* +3 for '<n>' where n is the log level */
+	char message[PATH_MAX + 30];	/* +3 for '<n>' where n is the log level and +27 for lvm2-activation-generator: " prefix */
 
-	snprintf(message, 4, "<%d>", LOG_ERR);
+	snprintf(message, 31, "<%d>lvm2-activation-generator: ", LOG_ERR);
 
 	va_start(ap, format);
-	n = vsnprintf(message + 3, PATH_MAX, format, ap);
+	n = vsnprintf(message + 30, PATH_MAX, format, ap);
 	va_end(ap);
 
 	if (_kmsg_fd < 0 || (n < 0 || ((unsigned) n + 1 > PATH_MAX)))
 		return;
 
-	/* The n+4: +3 for "<n>" prefix and +1 for '\0' suffix */
-	(void) write(_kmsg_fd, message, n + 4);
+	/* The n+31: +30 for "<n>lvm2-activation-generator: " prefix and +1 for '\0' suffix */
+	(void) write(_kmsg_fd, message, n + 31);
 }
 
 //----------------------------------------------------------------
@@ -112,7 +112,7 @@ static int register_unit_with_target(struct generator *gen, const char *unit,
 
 	(void) dm_prepare_selinux_context(gen->target_path, S_IFDIR);
 	if (mkdir(gen->target_path, 0755) < 0 && errno != EEXIST) {
-		_error("LVM: Failed to create target directory %s: %m.\n", gen->target_path);
+		_error("Failed to create target directory %s: %m.\n", gen->target_path);
 		r = 0;
 		goto out;
 	}
@@ -124,7 +124,7 @@ static int register_unit_with_target(struct generator *gen, const char *unit,
 	}
 	(void) dm_prepare_selinux_context(gen->target_path, S_IFLNK);
 	if (symlink(gen->unit_path, gen->target_path) < 0) {
-		_error("LVM: Failed to create symlink for unit %s: %m.\n", unit);
+		_error("Failed to create symlink for unit %s: %m.\n", unit);
 		r = 0;
 	}
  out:
@@ -144,7 +144,7 @@ static int generate_unit(struct generator *gen, int unit)
 		return 0;
 
 	if (!(f = fopen(gen->unit_path, "wxe"))) {
-		_error("LVM: Failed to create unit file %s: %m.\n", unit_name);
+		_error("Failed to create unit file %s: %m.\n", unit_name);
 		return 0;
 	}
 
@@ -181,12 +181,12 @@ static int generate_unit(struct generator *gen, int unit)
 	fputs("\nType=oneshot\n", f);
 
 	if (fclose(f) < 0) {
-		_error("LVM: Failed to write unit file %s: %m.\n", unit_name);
+		_error("Failed to write unit file %s: %m.\n", unit_name);
 		return 0;
 	}
 
 	if (!register_unit_with_target(gen, unit_name, target_name)) {
-		_error("LVM: Failed to register unit %s with target %s.\n",
+		_error("Failed to register unit %s with target %s.\n",
 		       unit_name, target_name);
 		return 0;
 	}
@@ -197,7 +197,7 @@ static int generate_unit(struct generator *gen, int unit)
 static bool _parse_command_line(struct generator *gen, int argc, const char **argv)
 {
 	if (argc != 4) {
-		_error("LVM: Incorrect number of arguments for activation generator.\n");
+		_error("Incorrect number of arguments for activation generator.\n");
 		return false;
 	}
 
@@ -239,7 +239,7 @@ int main(int argc, const char **argv)
 	_log_init();
 	r = _run(argc, argv);
 	if (!r)
-		_error("LVM: Activation generator failed.\n");
+		_error("Activation generator failed.\n");
 	_log_exit();
 
 	return r ? EXIT_SUCCESS : EXIT_FAILURE;


