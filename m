From: David Teigland <teigland@sourceware.org>
Date: Fri,  9 Apr 2021 20:50:30 +0000 (GMT)
Subject: dev-next - pvscan: don't get info from udev
Message-ID: <20210409205030.41DB93AA9819@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e2a2d8e23ff856d255f22389a5479e9a0d9fc77b
Commit:        e2a2d8e23ff856d255f22389a5479e9a0d9fc77b
Parent:        7ca8feec014c018698a178b6a30680ea50fab82b
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 9 15:49:26 2021 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 9 15:49:26 2021 -0500

pvscan: don't get info from udev

don't use obtain_device_info_from_udev since udev
will repeatedly return errors, stalling a command.
---
 tools/pvscan.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 29713dda6..9fa3a8b39 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -1839,6 +1839,17 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 		return ECMD_PROCESSED;
 	}
 
+	/*
+	 * Don't ask udev for info since pvscan is running from udev.
+	 * If a pvscan attempts to get dev info from udev, udev can
+	 * repeatedly return errors about the dev not being initialized
+	 * which will stall the pvscan.
+	 * FIXME: lvm commands should be changed to request and use udev
+	 * info if it's available, and if udev info is not immediately
+	 * available the command should just continue without it.
+	 */
+	init_obtain_device_list_from_udev(0);
+
 	if (arg_is_set(cmd, major_ARG) + arg_is_set(cmd, minor_ARG))
 		devno_args = 1;
 


