From: Alexander Tsoy <alexander@tsoy.me>
Date: Sun, 15 Sep 2013 16:26:27 +0400
Subject: [PATCH] systemd: lvm2-activation-generator: add missing ordering deps between generated units
Message-ID: <201309151311.r8FDBgTB032554@mx1.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

If two units run in parrallel, then one of them enter failing
state because device is busy:

"device-mapper: create ioctl on <VG-LV> failed: Device or resource
busy"

See: https://bugs.gentoo.org/show_bug.cgi?id=480066
---
 scripts/lvm2_activation_generator_systemd_red_hat.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
index 7e93d7d..cf6da2f 100644
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
@@ -134,8 +134,8 @@ static int generate_unit(const char *dir, int unit)
 	      "DefaultDependencies=no\n", f);
 
 	if (unit == UNIT_NET) {
-		fputs("After=iscsi.service fcoe.service\n"
-		      "Before=remote-fs.target shutdown.target\n\n"
+		fputs("After=lvm2-activation-early.service iscsi.service fcoe.service\n"
+		      "Before=lvm2-activation.service remote-fs.target shutdown.target\n\n"
 		      "[Service]\n"
 		      "ExecStartPre=/usr/bin/udevadm settle\n", f);
 	} else {
-- 
1.8.1.5


