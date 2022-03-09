From: David Teigland <teigland@sourceware.org>
Date: Wed,  9 Mar 2022 17:56:34 +0000 (GMT)
Subject: main - pvscan: don't use udev for external device info
Message-ID: <20220309175634.B491B3858C74@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=c7a5b5cca067496f5912bf992dcfedb6771dd083
Commit:        c7a5b5cca067496f5912bf992dcfedb6771dd083
Parent:        bef1363c0064f42e8063571143a428ad163d1bd9
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Mar 9 11:54:59 2022 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 9 11:54:59 2022 -0600

pvscan: don't use udev for external device info

pvscan is used to populate udev info, so it can't expect
to use that udev info.
---
 tools/pvscan.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index dcf183a46..db6709a5a 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -1710,13 +1710,11 @@ int pvscan_cache_cmd(struct cmd_context *cmd, int argc, char **argv)
 	}
 
 	/*
-	 * If obtain_device_list_from_udev was set to 1, force it to 0.
-	 * Don't ask udev for info since pvscan is running from udev.
-	 * If a pvscan attempts to get dev info from udev, udev can
-	 * repeatedly return errors about the dev not being initialized
-	 * which will stall the pvscan.
+	 * Do not use udev for device listing or device info because pvscan
+	 * is used to populate udev info.
 	 */
 	init_obtain_device_list_from_udev(0);
+	init_external_device_info_source(DEV_EXT_NONE);
 
 	if (arg_is_set(cmd, major_ARG) + arg_is_set(cmd, minor_ARG))
 		devno_args = 1;

