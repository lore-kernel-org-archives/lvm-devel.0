From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Oct 2012 13:00:29 +0000 (UTC)
Subject: master - scripts: blk-availability should be stopped before FCoE
Message-ID: <20121015130029.EEE291C99@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d365bfe7e96b23297d3aac3485f98998bb220613
Commit:        d365bfe7e96b23297d3aac3485f98998bb220613
Parent:        d864c6eacd3e2f40034eb583cb2df9fa7c72efbe
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Oct 15 14:50:17 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Oct 15 15:00:12 2012 +0200

scripts: blk-availability should be stopped before FCoE

---
 scripts/blk_availability_init_red_hat.in           |    2 +-
 .../blk_availability_systemd_red_hat.service.in    |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/scripts/blk_availability_init_red_hat.in b/scripts/blk_availability_init_red_hat.in
index 618f3d3..60dd240 100644
--- a/scripts/blk_availability_init_red_hat.in
+++ b/scripts/blk_availability_init_red_hat.in
@@ -15,7 +15,7 @@
 # devices that were created using the -m option of lvcreate.
 #
 #
-# chkconfig: 12345 10 80
+# chkconfig: 12345 25 75
 # description: Controls availability of block devices
 #
 # For Red-Hat-based distributions such as Fedora, RHEL, CentOS.
diff --git a/scripts/blk_availability_systemd_red_hat.service.in b/scripts/blk_availability_systemd_red_hat.service.in
index fef919b..9c1cb78 100644
--- a/scripts/blk_availability_systemd_red_hat.service.in
+++ b/scripts/blk_availability_systemd_red_hat.service.in
@@ -1,6 +1,6 @@
 [Unit]
 Description=Availability of block devices
-After=lvm2-activation.service lvm2-lvmetad.service iscsi.service iscsid.service
+After=lvm2-activation.service lvm2-lvmetad.service iscsi.service iscsid.service fcoe.service
 DefaultDependencies=no
 Conflicts=shutdown.target
 


