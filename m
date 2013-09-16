From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 16 Sep 2013 10:00:14 +0000 (UTC)
Subject: master - systemd: run lvm2-activation-net.service after lvm2-activation.service
Message-ID: <20130916100014.DD131614D4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9742c5192e8871ebde12856170dae70ee861ef40
Commit:        9742c5192e8871ebde12856170dae70ee861ef40
Parent:        fbb732bd8eb5308eeb1dc7cc6d747552844018ac
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Sep 16 11:47:09 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Sep 16 11:47:09 2013 +0200

systemd: run lvm2-activation-net.service after lvm2-activation.service

The lvm2-activation-net.service was ordered only with respect to iscsi
and fcoe service before. In addition to that, we also need ordering
with respect to lvm2-activation.service to prevent parallel vgchange -aay
runs which may cause some problems during activation.
See also https://bugs.gentoo.org/show_bug.cgi?id=480066.

With this patch, the ordering is firmly set to:
lvm2-activation-early.service -> lvm2-activation.service -> lvm2-activation-net.service

Thanks to Alexander Tsoy for the original patch (modified a bit here):
https://www.redhat.com/archives/lvm-devel/2013-September/msg00049.html
---
 WHATS_NEW                                          |    1 +
 .../lvm2_activation_generator_systemd_red_hat.c    |   10 +++++-----
 2 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a46b0b4..1c4925b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.101 - 
 ===================================
+  Run lvm2-activation-net after lvm2-activation service to prevent parallel run.
   Add man page entries for lvmdump's -u and -l options.
   Fix lvm2app segfault while using lvm_list_pvs_free fn if there are no PVs.
   Improve of clvmd singlenode locking simulation.
diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
index 7e93d7d..f2e2e49 100644
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
@@ -134,16 +134,16 @@ static int generate_unit(const char *dir, int unit)
 	      "DefaultDependencies=no\n", f);
 
 	if (unit == UNIT_NET) {
-		fputs("After=iscsi.service fcoe.service\n"
-		      "Before=remote-fs.target shutdown.target\n\n"
-		      "[Service]\n"
-		      "ExecStartPre=/usr/bin/udevadm settle\n", f);
+		fprintf(f, "After=%s iscsi.service fcoe.service\n"
+			"Before=remote-fs.target shutdown.target\n\n"
+			"[Service]\n"
+			"ExecStartPre=/usr/bin/udevadm settle\n", unit_names[UNIT_MAIN]);
 	} else {
 		if (unit == UNIT_EARLY) {
 			fputs("After=systemd-udev-settle.service\n"
 			      "Before=cryptsetup.target\n", f);
 		} else
-			fputs("After=lvm2-activation-early.service cryptsetup.target\n", f);
+			fprintf(f, "After= %s cryptsetup.target\n", unit_names[UNIT_EARLY]);
 
 		fputs("Before=local-fs.target shutdown.target\n"
 		      "Wants=systemd-udev-settle.service\n\n"


