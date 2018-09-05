From: Marian Csontos <mcsontos@sourceware.org>
Date: Wed, 5 Sep 2018 09:02:33 -0400
Subject: 2018-06-01-stable - scripts: add After=rbdmap.service to {lvm2-activation-net, blk-availability}.service
Message-ID: <201809051302.w85D2XF5010826@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3374a592502ef099d38491b0c2020a6945d825b1
Commit:        3374a592502ef099d38491b0c2020a6945d825b1
Parent:        6afb911252adf73c3bce2c708cc647866d144103
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Aug 30 12:35:58 2018 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Sep 5 14:41:55 2018 +0200

scripts: add After=rbdmap.service to {lvm2-activation-net,blk-availability}.service

We need to have Ceph RBD devices mapped first before use in a stack
where LVM is on top so make sure rbdmap.service is called before
generated lvm2-activation-net.service.

On shutdown, we need to stop blk-availability first before we stop the
rbdmap.service.

Resolves: rhbz1623479
(cherry picked from commit cb17ef221bdefea3625a22c19c6d8f5504441771)

Conflicts:
	WHATS_NEW
---
 WHATS_NEW                                          |    1 +
 .../blk_availability_systemd_red_hat.service.in    |    2 +-
 .../lvm2_activation_generator_systemd_red_hat.c    |    2 +-
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 85f4ed1..8def00d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.182 - 
 ==============================
+  Add After=rbdmap.service to {lvm2-activation-net,blk-availability}.service.
   Fix pvs with lvmetad to avoid too many open files from filter reads.
   Fix pvscan --cache to avoid too many open files from filter reads.
   Reduce max concurrent aios to avoid EMFILE with many devices.
diff --git a/scripts/blk_availability_systemd_red_hat.service.in b/scripts/blk_availability_systemd_red_hat.service.in
index 1198baa..9462072 100644
--- a/scripts/blk_availability_systemd_red_hat.service.in
+++ b/scripts/blk_availability_systemd_red_hat.service.in
@@ -1,6 +1,6 @@
 [Unit]
 Description=Availability of block devices
-After=lvm2-activation.service lvm2-lvmetad.service iscsi-shutdown.service iscsi.service iscsid.service fcoe.service
+After=lvm2-activation.service lvm2-lvmetad.service iscsi-shutdown.service iscsi.service iscsid.service fcoe.service rbdmap.service
 DefaultDependencies=no
 Conflicts=shutdown.target
 
diff --git a/scripts/lvm2_activation_generator_systemd_red_hat.c b/scripts/lvm2_activation_generator_systemd_red_hat.c
index 0f7f89c..487582f 100644
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
@@ -128,7 +128,7 @@ static int generate_unit(const char *dir, int unit, int sysinit_needed)
 	      "DefaultDependencies=no\n", f);
 
 	if (unit == UNIT_NET) {
-		fprintf(f, "After=%s iscsi.service fcoe.service\n"
+		fprintf(f, "After=%s iscsi.service fcoe.service rbdmap.service\n"
 			"Before=remote-fs-pre.target shutdown.target\n\n"
 			"[Service]\n"
 			"ExecStartPre=/usr/bin/udevadm settle\n", unit_names[UNIT_MAIN]);


