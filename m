From: David Teigland <teigland@sourceware.org>
Date: Mon, 25 Oct 2021 17:14:02 +0000 (GMT)
Subject: main - vgimportdevices: skip lvmlockd locking
Message-ID: <20211025171402.A7F5C3858400@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b65a2c3f3a76739fb75a4a3a868cc9f143740052
Commit:        b65a2c3f3a76739fb75a4a3a868cc9f143740052
Parent:        221e75316f472fbf5eb2ad206b861ea255c099ed
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Oct 25 12:11:17 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Oct 25 12:11:17 2021 -0500

vgimportdevices: skip lvmlockd locking

Help bootstrapping existing shared vgs into the devices file.
Reading the vg in vgimportdevices would require locking to be
started, but vgchange lockstart won't see the vg if it's not
in the devices file.  The lvmlockd locks are not protecting
vg modifications so skipping them here won't be a problem.
---
 tools/vgimportdevices.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/tools/vgimportdevices.c b/tools/vgimportdevices.c
index 3f315f98f..2580613c4 100644
--- a/tools/vgimportdevices.c
+++ b/tools/vgimportdevices.c
@@ -172,6 +172,17 @@ int vgimportdevices(struct cmd_context *cmd, int argc, char **argv)
 	cmd->filter_regex_with_devices_file = 1;
 	cmd->create_edit_devices_file = 1;
 
+	/*
+	 * This helps a user bootstrap existing shared VGs into the devices
+	 * file. Reading the vg to import devices requires locking, but
+	 * lockstart won't find the vg before it's in the devices file.
+	 * So, allow importing devices without an lvmlockd lock (in a
+	 * a shared vg the vg metadata won't be updated with device ids,
+	 * so the lvmlockd lock isn't protecting vg modification.)
+	 */
+	cmd->lockd_gl_disable = 1;
+	cmd->lockd_vg_disable = 1;
+
 	/*
 	 * For each VG:
 	 * device_id_add() each PV in the VG


