From: David Teigland <teigland@sourceware.org>
Date: Fri, 25 Mar 2022 19:15:25 +0000 (GMT)
Subject: main - vgchange monitor: don't use udev info
Message-ID: <20220325191525.ACD97385E44F@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=72f0b637d239c893ca49b05b83e2ebddc327e900
Commit:        72f0b637d239c893ca49b05b83e2ebddc327e900
Parent:        c7a5b5cca067496f5912bf992dcfedb6771dd083
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Mar 25 14:13:56 2022 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Mar 25 14:13:56 2022 -0500

vgchange monitor: don't use udev info

vgchange --monitor y is run during startup when udev is being
initialized and is not yet ready to be used.
---
 tools/vgchange.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/tools/vgchange.c b/tools/vgchange.c
index fc076c1d5..09ade96a6 100644
--- a/tools/vgchange.c
+++ b/tools/vgchange.c
@@ -992,6 +992,17 @@ int vgchange(struct cmd_context *cmd, int argc, char **argv)
 			return ECMD_PROCESSED;
 	}
 
+	/*
+	 * Do not use udev for device listing or device info because
+	 * vgchange --monitor y is called during boot when udev is being
+	 * initialized and is not yet ready to be used.
+	 */
+	if (arg_is_set(cmd, monitor_ARG) &&
+	    arg_int_value(cmd, monitor_ARG, DEFAULT_DMEVENTD_MONITOR)) {
+		init_obtain_device_list_from_udev(0);
+		init_external_device_info_source(DEV_EXT_NONE);
+	}
+
 	if (update)
 		flags |= READ_FOR_UPDATE;
 	else if (arg_is_set(cmd, activate_ARG))

