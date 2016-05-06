From: David Teigland <teigland@fedoraproject.org>
Date: Fri,  6 May 2016 14:00:58 +0000 (UTC)
Subject: master - lvmetad: add duplicate resolution advice
Message-ID: <20160506140058.E8B5B60722@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e84fb639f03b018b7b6f09778f863c50a7f9e045
Commit:        e84fb639f03b018b7b6f09778f863c50a7f9e045
Parent:        b1ea27b1e210274dfb9c7100cf0f9714397eec3b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue May 3 15:56:34 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri May 6 09:00:00 2016 -0500

lvmetad: add duplicate resolution advice

---
 tools/lvmcmdline.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/tools/lvmcmdline.c b/tools/lvmcmdline.c
index e6c82cf..fa9cd8f 100644
--- a/tools/lvmcmdline.c
+++ b/tools/lvmcmdline.c
@@ -1677,6 +1677,13 @@ int lvm_run_command(struct cmd_context *cmd, int argc, char **argv)
 		if (lvmetad_used() && lvmetad_is_disabled(cmd, &reason)) {
 			log_warn("WARNING: Not using lvmetad because %s.", reason);
 			lvmetad_make_unused(cmd);
+
+			if (strstr(reason, "duplicate")) {
+				log_warn("WARNING: Use multipath or vgimportclone to resolve duplicate PVs?");
+				if (!find_config_tree_bool(cmd, devices_multipath_component_detection_CFG, NULL))
+					log_warn("WARNING: Set multipath_component_detection=1 to hide multipath duplicates.");
+				log_warn("WARNING: After duplicates are resolved, run \"pvscan --cache\" to enable lvmetad.");
+			}
 		}
 	}
 


