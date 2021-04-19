From: David Teigland <teigland@sourceware.org>
Date: Mon, 19 Apr 2021 18:29:41 +0000 (GMT)
Subject: main - config: improve description for event_activation
Message-ID: <20210419182941.694BD385E02F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a616abba03a35ec3064360ac8cab9ebb2203d645
Commit:        a616abba03a35ec3064360ac8cab9ebb2203d645
Parent:        5eac292925ca96bee9a1f50355ca0e8b0ef4a9a6
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Apr 19 13:29:17 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Apr 19 13:29:17 2021 -0500

config: improve description for event_activation

---
 lib/config/config_settings.h | 15 ++++++++-------
 1 file changed, 8 insertions(+), 7 deletions(-)

diff --git a/lib/config/config_settings.h b/lib/config/config_settings.h
index 3946a7129..d3a42a153 100644
--- a/lib/config/config_settings.h
+++ b/lib/config/config_settings.h
@@ -1117,13 +1117,14 @@ cfg(global_lvdisplay_shows_full_device_path_CFG, "lvdisplay_shows_full_device_pa
 
 cfg(global_event_activation_CFG, "event_activation", global_CFG_SECTION, CFG_DEFAULT_COMMENTED, CFG_TYPE_BOOL, 1, vsn(2, 3, 1), 0, 0, NULL,
 	"Activate LVs based on system-generated device events.\n"
-	"When a device appears on the system, a system-generated event runs\n"
-	"the pvscan command to activate LVs if the new PV completes the VG.\n"
-	"When event_activation is disabled, the system will generally run\n"
-	"a direct activation command to activate LVs in complete VGs.\n"
-	"Activation commands that are run by the system, either from events\n"
-	"or at fixed points during startup, use autoactivation (-aay).  See\n"
-	"the --setautoactivation option or the auto_activation_volume_list\n"
+	"When a PV appears on the system, a system-generated uevent triggers\n"
+	"the lvm2-pvscan service which runs the pvscan --cache -aay command.\n"
+	"If the new PV completes a VG, pvscan autoactivates LVs in the VG.\n"
+	"When event_activation is disabled, the lvm2-activation services are\n"
+	"generated and run at fixed points during system startup.  These\n"
+	"services run vgchange -aay to autoactivate LVs in VGs that happen\n"
+	"to be present at that point in time.\n"
+	"See the --setautoactivation option or the auto_activation_volume_list\n"
 	"setting to configure autoactivation for specific VGs or LVs.\n")
 
 cfg(global_use_lvmetad_CFG, "use_lvmetad", global_CFG_SECTION, 0, CFG_TYPE_BOOL, 0, vsn(2, 2, 93), 0, vsn(2, 3, 0), NULL,


