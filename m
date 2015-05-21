From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 21 May 2015 10:20:34 +0000 (UTC)
Subject: master - scripts: activation generator: do not use --sysinit if lvmpolld used
Message-ID: <20150521102034.81CCF60067@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ba68aed8366c201ab0a263a9935243a9e6f08875
Commit:        ba68aed8366c201ab0a263a9935243a9e6f08875
Parent:        6d998aa13df81e5cec339c86a63dac934de3da35
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu May 21 11:07:07 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu May 21 12:20:30 2015 +0200

scripts: activation generator: do not use --sysinit if lvmpolld used

If lvmetad is not used, we generate lvm2-activation{-early,-net}.service
systemd services to activate any VGs found on the system. So far we used
--sysinit during this activation as polling was still forked off of the
lvm activation command.

This has changed with lvmpolld - we have proper lvmpolld systemd
service now (activated via its socket unit). As such, we don't need
to use --sysinit anymore during activation in systemd environment
as polling was the only barrier to remove the need for --sysinit.
---
 WHATS_NEW                                          |    1 +
 .../lvm2_activation_generator_systemd_red_hat.c    |   37 ++++++++++++--------
 2 files changed, 23 insertions(+), 15 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index e14c858..eecdca9 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.121 - 
 ================================
+  Do not use --sysinit in lvm2-activation{-early,-net}.service if lvmpolld used.
   Do not fail polling when poll LV not found (already finished or removed).
   Replace poll_get_copy_vg/lv fns with vg_read() and find_lv() in polldaemon.
   Close all device fds only in before sleep call in polldaemon.
diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
index 6a003f5..92c08d3 100644
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
@@ -24,8 +24,9 @@
 #include "lvm2app.h"
 #include "configure.h"		/* for LVM_PATH */
 
-#define KMSG_DEV_PATH        "/dev/kmsg"
-#define LVM_CONF_USE_LVMETAD "global/use_lvmetad"
+#define KMSG_DEV_PATH		"/dev/kmsg"
+#define LVM_CONF_USE_LVMETAD	"global/use_lvmetad"
+#define LVM_CONF_USE_LVMPOLLD	"global/use_lvmpolld"
 
 #define UNIT_TARGET_LOCAL_FS  "local-fs.target"
 #define UNIT_TARGET_REMOTE_FS "remote-fs.target"
@@ -66,19 +67,18 @@ static void kmsg(int log_level, const char *format, ...)
 	(void) write(kmsg_fd, message, n + 4);
 }
 
-static int lvm_uses_lvmetad(void)
+static void lvm_get_use_lvmetad_and_lvmpolld(int *use_lvmetad, int *use_lvmpolld)
 {
 	lvm_t lvm;
-	int r;
 
+	*use_lvmetad = *use_lvmpolld = 0;
 	if (!(lvm = lvm_init(NULL))) {
 		kmsg(LOG_ERR, "LVM: Failed to initialize library context for activation generator.\n");
-		return 0;
+		return;
 	}
-	r = lvm_config_find_bool(lvm, LVM_CONF_USE_LVMETAD, 0);
+	*use_lvmetad = lvm_config_find_bool(lvm, LVM_CONF_USE_LVMETAD, 0);
+	*use_lvmpolld = lvm_config_find_bool(lvm, LVM_CONF_USE_LVMPOLLD, 0);
 	lvm_quit(lvm);
-
-	return r;
 }
 
 static int register_unit_with_target(const char *dir, const char *unit, const char *target)
@@ -107,7 +107,7 @@ out:
 	return r;
 }
 
-static int generate_unit(const char *dir, int unit)
+static int generate_unit(const char *dir, int unit, int sysinit_needed)
 {
 	FILE *f;
 	const char *unit_name = unit_names[unit];
@@ -150,8 +150,10 @@ static int generate_unit(const char *dir, int unit)
 		      "[Service]\n", f);
 	}
 
-	fputs("ExecStart=" LVM_PATH " vgchange -aay --sysinit --ignoreskippedcluster\n"
-	      "Type=oneshot\n", f);
+	fputs("ExecStart=" LVM_PATH " vgchange -aay --ignoreskippedcluster", f);
+	if (sysinit_needed)
+		fputs (" --sysinit", f);
+	fputs("\nType=oneshot\n", f);
 
 	if (fclose(f) < 0) {
 		kmsg(LOG_ERR, "LVM: Failed to write unit file %s: %m.\n", unit_name);
@@ -168,6 +170,7 @@ static int generate_unit(const char *dir, int unit)
 
 int main(int argc, char *argv[])
 {
+	int use_lvmetad, use_lvmpolld, sysinit_needed;
 	const char *dir;
 	int r = EXIT_SUCCESS;
 	mode_t old_mask;
@@ -180,16 +183,20 @@ int main(int argc, char *argv[])
 	}
 
 	/* If lvmetad used, rely on autoactivation instead of direct activation. */
-	if (lvm_uses_lvmetad())
+	lvm_get_use_lvmetad_and_lvmpolld(&use_lvmetad, &use_lvmpolld);
+	if (use_lvmetad)
 		goto out;
 
 	dir = argv[1];
 
 	/* mark lvm2-activation.*.service as world-accessible */
 	old_mask = umask(0022);
-	if (!generate_unit(dir, UNIT_EARLY) ||
-	    !generate_unit(dir, UNIT_MAIN) ||
-	    !generate_unit(dir, UNIT_NET))
+
+	sysinit_needed = !use_lvmpolld;
+
+	if (!generate_unit(dir, UNIT_EARLY, sysinit_needed) ||
+	    !generate_unit(dir, UNIT_MAIN, sysinit_needed) ||
+	    !generate_unit(dir, UNIT_NET, sysinit_needed))
 		r = EXIT_FAILURE;
 	umask(old_mask);
 out:


