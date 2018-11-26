From: David Teigland <teigland@sourceware.org>
Date: Mon, 26 Nov 2018 15:52:36 -0500
Subject: master - pvscan systemd service for event based activation
Message-ID: <201811262052.wAQKqa71032149@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4b5d6de86b3fd3a06b913708e477b603627c8614
Commit:        4b5d6de86b3fd3a06b913708e477b603627c8614
Parent:        229e63b6388ae384fad08dfbf659b360b95753bc
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Nov 26 12:49:39 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Nov 26 14:33:31 2018 -0600

pvscan systemd service for event based activation

The pvscan systemd service for autoactivation was
mistakenly dropped along with the lvmetad related
services.

The activation generator program now looks at the new
lvm.conf setting "event_activation" (default 1) to
switch between event activation and direct activation.

Previously, the old use_lvmetad setting was used to
switch between event and direct activation.
---
 configure.ac                                       |    1 +
 lib/config/config_settings.h                       |    9 +++++++++
 man/lvm2-activation-generator.8_main               |    4 ++--
 scripts/Makefile.in                                |    1 +
 scripts/generator-internals.c                      |   14 +++++++-------
 scripts/lvm2-pvscan.service.in                     |   14 ++++++++++++++
 .../lvm2_activation_generator_systemd_red_hat.c    |   13 ++++++-------
 7 files changed, 40 insertions(+), 16 deletions(-)

diff --git a/configure.ac b/configure.ac
index 8549a80..ffec809 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1828,6 +1828,7 @@ libdm/dm-tools/Makefile
 libdm/libdevmapper.pc
 man/Makefile
 po/Makefile
+scripts/lvm2-pvscan.service
 scripts/blkdeactivate.sh
 scripts/blk_availability_init_red_hat
 scripts/blk_availability_systemd_red_hat.service
diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 29ec980..f4f626f 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -997,6 +997,15 @@ cfg(global_lvdisplay_shows_full_device_path_CFG, "lvdisplay_shows_full_device_pa
 	"Previously this was always shown as /dev/vgname/lvname even when that\n"
 	"was never a valid path in the /dev filesystem.\n")
 
+cfg(global_event_activation_CFG, "event_activation", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 1, vsn(2, 3, 1), 0, 0, NULL,
+	"Activate LVs based on system-generated device events.\n"
+	"When a device appears on the system, a system-generated event runs\n"
+	"the pvscan command to activate LVs if the new PV completes the VG.\n"
+	"Use auto_activation_volume_list to select which LVs should be\n"
+	"activated from these events (the default is all.)\n"
+	"When event_activation is disabled, the system will generally run\n"
+	"a direct activation command to activate LVs in complete VGs.\n")
+
 cfg(global_use_lvmetad_CFG, "use_lvmetad", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 2, 93), 0, vsn(3, 0, 0), NULL,
 	"This setting is no longer used.\n")
 
diff --git a/man/lvm2-activation-generator.8_main b/man/lvm2-activation-generator.8_main
index 066751d..ba7fd0d 100644
--- a/man/lvm2-activation-generator.8_main
+++ b/man/lvm2-activation-generator.8_main
@@ -8,10 +8,10 @@ lvm2-activation-generator - generator for systemd units to activate LVM volumes
 
 The lvm2-activation-generator is called by \fBsystemd\fP(1) on boot to
 generate systemd units at runtime to activate LVM Logical Volumes (LVs)
-when global/use_lvmetad=0 is set in \fBlvm.conf\fP(5).  These units use
+when global/event_activation=0 is set in \fBlvm.conf\fP(5).  These units use
 \fBvgchange -ay\fP to activate LVs.
 
-If use_lvmetad=1, the lvm2-activation-generator exits immediately without
+If event_activation=1, the lvm2-activation-generator exits immediately without
 generating any systemd units, and LVM fully relies on event-based
 activation to activate LVs.  In this case, event-generated \fBpvscan
 --cache -aay\fP commands activate LVs.
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 27fc201..12d37d0 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -84,6 +84,7 @@ install_systemd_generators:
 
 install_systemd_units:	install_dbus_service
 	$(INSTALL_DIR) $(systemd_unit_dir)
+	$(INSTALL_DATA) lvm2-pvscan.service $(systemd_unit_dir)/lvm2-pvscan at .service
 ifeq ("@BUILD_DMEVENTD@", "yes")
 	$(INSTALL_DATA) dm_event_systemd_red_hat.socket $(systemd_unit_dir)/dm-event.socket
 	$(INSTALL_DATA) dm_event_systemd_red_hat.service $(systemd_unit_dir)/dm-event.service
diff --git a/scripts/generator-internals.c b/scripts/generator-internals.c
index 5acc969..9619e8c 100644
--- a/scripts/generator-internals.c
+++ b/scripts/generator-internals.c
@@ -93,11 +93,11 @@ static bool _close_child(struct child_process *child)
 //----------------------------------------------------------------
 // Aquiring config from the lvmconfig process
 
-#define LVM_CONF_USE_LVMETAD	"global/use_lvmetad"
-#define LVM_CONF_USE_LVMPOLLD	"global/use_lvmpolld"
+#define LVM_CONF_EVENT_ACTIVATION "global/event_activation"
+#define LVM_CONF_USE_LVMPOLLD	  "global/use_lvmpolld"
 
 struct config {
-	bool use_lvmetad;
+	bool event_activation;
 	bool sysinit_needed;
 };
 
@@ -153,8 +153,8 @@ static bool _parse_line(const char *line, struct config *cfg)
 {
 	const char *val;
 
-	if (_begins_with(line, "use_lvmetad=", &val)) {
-		return _parse_bool(val, &cfg->use_lvmetad);
+	if (_begins_with(line, "event_activation=", &val)) {
+		return _parse_bool(val, &cfg->event_activation);
 
 	} else if (_begins_with(line, "use_lvmpolld=", &val)) {
 		bool r;
@@ -170,14 +170,14 @@ static bool _parse_line(const char *line, struct config *cfg)
 static bool _get_config(struct config *cfg, const char *lvmconfig_path)
 {
 	static const char *_argv[] = {
-		"lvmconfig", LVM_CONF_USE_LVMETAD, LVM_CONF_USE_LVMPOLLD, NULL
+		"lvmconfig", LVM_CONF_EVENT_ACTIVATION, LVM_CONF_USE_LVMPOLLD, NULL
 	};
 
 	bool r = true;
 	char buffer[256];
 	struct child_process child;
 
-	cfg->use_lvmetad = false;
+	cfg->event_activation = false;
 	cfg->sysinit_needed = true;
 
 	if (!_open_child(&child, lvmconfig_path, _argv)) {
diff --git a/scripts/lvm2-pvscan.service.in b/scripts/lvm2-pvscan.service.in
new file mode 100644
index 0000000..93fe062
--- /dev/null
+++ b/scripts/lvm2-pvscan.service.in
@@ -0,0 +1,14 @@
+[Unit]
+Description=LVM event activation on device %i
+Documentation=man:pvscan(8)
+DefaultDependencies=no
+StartLimitInterval=0
+BindsTo=dev-block-%i.device
+Before=shutdown.target
+Conflicts=shutdown.target
+
+[Service]
+Type=oneshot
+RemainAfterExit=yes
+ExecStart=@SBINDIR@/lvm pvscan --cache --activate ay %i
+ExecStop=@SBINDIR@/lvm pvscan --cache %i
diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
index 5dc39ae..0e6c05a 100644
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
@@ -150,12 +150,11 @@ static int generate_unit(struct generator *gen, int unit)
 
 	fputs("# Automatically generated by lvm2-activation-generator.\n"
 	      "#\n"
-	      "# This unit is responsible for direct activation of LVM2 logical volumes\n"
-	      "# if lvmetad daemon is not used (global/use_lvmetad=0 lvm.conf setting),\n"
-	      "# hence volume autoactivation is not applicable.\n"
-	      "# Direct LVM2 activation requires udev to be settled!\n\n"
+	      "# This unit is responsible for direct activation of LVM logical volumes\n"
+	      "# if event-based activation not used (global/event_activation=0 in\n"
+	      "# lvm.conf). Direct LVM activation requires udev to be settled!\n\n"
 	      "[Unit]\n"
-	      "Description=Activation of LVM2 logical volumes\n"
+	      "Description=LVM direct activation of logical volumes\n"
 	      "Documentation=man:lvm2-activation-generator(8)\n"
 	      "SourcePath=/etc/lvm/lvm.conf\n" "DefaultDependencies=no\n", f);
 
@@ -217,8 +216,8 @@ static bool _run(int argc, const char **argv)
 	if (!_get_config(&gen.cfg, LVMCONFIG_PATH))
 		return false;
 
-	if (gen.cfg.use_lvmetad)
-		// If lvmetad used, rely on autoactivation instead of direct activation.
+	if (gen.cfg.event_activation)
+		// If event_activation=1, pvscan --cache -aay does activation.
 		return true;
 
 	/* mark lvm2-activation.*.service as world-accessible */


