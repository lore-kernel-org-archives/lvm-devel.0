From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 8 Jan 2019 07:16:12 -0500
Subject: master - scripts: lvm2-activation-generator fix lvmconfig call
Message-ID: <201901081216.x08CGCk2031553@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6298eaeca50e32cdff3adefdb57b09c3250547a2
Commit:        6298eaeca50e32cdff3adefdb57b09c3250547a2
Parent:        bc40391b7de93334c815565240848d5297f7a6c8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jan 4 11:11:13 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jan 8 13:11:46 2019 +0100

scripts: lvm2-activation-generator fix lvmconfig call

Fix a scenario where global/event_activation setting is not found. In
this case we need to take default value just like lvm tools do when
executed. So use "lvmconfig --type full".

Also, if we fail to execute lvmconfig for whatever reason, fallback to
generating the activation units as failsafe action.

Reported by: Bastian Blank <waldi debian org>
---
 WHATS_NEW                                          |    1 +
 scripts/generator-internals.c                      |    3 ++-
 .../lvm2_activation_generator_systemd_red_hat.c    |   15 ++++++++++-----
 3 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3fe1f3e..6fdde83 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.03.02 - 
 ===================================
+  Fix generator quering lvmconfig unpresent config option.
   Fix memleak on bcache error path code.
   Fix missing unlock on lvm2 dmeventd plugin error path initialization.
   Improve Makefile dependency tracking.
diff --git a/scripts/generator-internals.c b/scripts/generator-internals.c
index 0929b78..8392065 100644
--- a/scripts/generator-internals.c
+++ b/scripts/generator-internals.c
@@ -186,7 +186,8 @@ static bool _parse_line(const char *line, struct config *cfg)
 static bool _get_config(struct config *cfg, const char *lvmconfig_path)
 {
 	static const char *_argv[] = {
-		"lvmconfig", LVM_CONF_EVENT_ACTIVATION, LVM_CONF_USE_LVMPOLLD, NULL
+		"lvmconfig", "--type", "full",
+		LVM_CONF_EVENT_ACTIVATION, LVM_CONF_USE_LVMPOLLD, NULL
 	};
 
 	bool r = true;
diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
index a3a3e88..f906f08 100644
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
@@ -194,12 +194,17 @@ static bool _run(int argc, const char **argv)
 	if (!_parse_command_line(&gen, argc, argv))
 		return false;
 
-	if (!_get_config(&gen.cfg, LVMCONFIG_PATH))
-		return false;
+	if (_get_config(&gen.cfg, LVMCONFIG_PATH)) {
+		if (gen.cfg.event_activation)
+			// If event_activation=1, pvscan --cache -aay does activation.
+			return true;
+	}
 
-	if (gen.cfg.event_activation)
-		// If event_activation=1, pvscan --cache -aay does activation.
-		return true;
+	/*
+	 *  Create the activation units if:
+	 *    - _get_config succeeded and event_activation=0
+	 *    - _get_config failed, then this is a failsafe fallback
+	 */
 
 	/* mark lvm2-activation.*.service as world-accessible */
 	old_mask = umask(0022);


