From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Thu, 30 Aug 2018 07:16:19 -0400
Subject: master - scripts: add After=rbdmap.service to {lvm2-activation-net, blk-availability}.service
Message-ID: <201808301116.w7UBGJYN012941@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cb17ef221bdefea3625a22c19c6d8f5504441771
Commit:        cb17ef221bdefea3625a22c19c6d8f5504441771
Parent:        fade9ca3b6ee1432ae8c2878815bbf871cacf92d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Aug 30 12:35:58 2018 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Aug 30 12:35:58 2018 +0200

scripts: add After=rbdmap.service to {lvm2-activation-net,blk-availability}.service

We need to have Ceph RBD devices mapped first before use in a stack
where LVM is on top so make sure rbdmap.service is called before
generated lvm2-activation-net.service.

On shutdown, we need to stop blk-availability first before we stop the
rbdmap.service.

Resolves: rhbz1623479
---
 WHATS_NEW                                          |    1 +
 .../blk_availability_systemd_red_hat.service.in    |    2 +-
 .../lvm2_activation_generator_systemd_red_hat.c    |    2 +-
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index bf03c49..8489252 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 3.0.0
 =============
+  Add After=rbdmap.service to {lvm2-activation-net,blk-availability}.service.
   Reduce max concurrent aios to avoid EMFILE with many devices.
   Fix lvconvert conversion attempts to linear.
   Fix lvconvert raid0/raid0_meta -> striped regression.
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
index b3d18d2..b751841 100644
--- a/scripts/lvm2_activation_generator_systemd_red_hat.c
+++ b/scripts/lvm2_activation_generator_systemd_red_hat.c
@@ -160,7 +160,7 @@ static int generate_unit(struct generator *gen, int unit)
 	      "SourcePath=/etc/lvm/lvm.conf\n" "DefaultDependencies=no\n", f);
 
 	if (unit == UNIT_NET) {
-		fprintf(f, "After=%s iscsi.service fcoe.service\n"
+		fprintf(f, "After=%s iscsi.service fcoe.service rbdmap.service\n"
 			"Before=remote-fs-pre.target shutdown.target\n\n"
 			"[Service]\n"
 			"ExecStartPre=/usr/bin/udevadm settle\n", _unit_names[UNIT_MAIN]);


