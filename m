From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri, 13 Mar 2015 11:09:19 +0000 (UTC)
Subject: master - systemd: blk-availability.service: add After=iscsi-shutdown.service
Message-ID: <20150313110919.1CB2A60EBF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=05f23e77634b2ed3d7861511c07ed73a3bb6d096
Commit:        05f23e77634b2ed3d7861511c07ed73a3bb6d096
Parent:        c6d96efc38b2d1af9e81d96f27f17eea90fe7623
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Mar 13 12:05:47 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Mar 13 12:08:20 2015 +0100

systemd: blk-availability.service: add After=iscsi-shutdown.service

The iscsi-shutdown.service is the one responsible for logging out
iscsi sessions so blk-availability.service (running the blkdeactivate
script) should be run before that on shutdown (so we need to use
After=iscsi-shutdown.service because "After" relates to starting
the service and the opposite order is automatically applied on
stopping the service at shutdown).
---
 WHATS_NEW                                          |    1 +
 .../blk_availability_systemd_red_hat.service.in    |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index b4fd415..97b562d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.118 - 
 =================================
+  Add After=iscsi-shutdown.service to blk-availability.service systemd unit.
   Disallow vgconvert from changing metadata format when lvmetad is used.
   Don't do a full read of VG when creating a new VG with an existing name.
   Reduce number of VG metadata parsing when looking for vgname on a PV.
diff --git a/scripts/blk_availability_systemd_red_hat.service.in b/scripts/blk_availability_systemd_red_hat.service.in
index 9c1cb78..3506738 100644
--- a/scripts/blk_availability_systemd_red_hat.service.in
+++ b/scripts/blk_availability_systemd_red_hat.service.in
@@ -1,6 +1,6 @@
 [Unit]
 Description=Availability of block devices
-After=lvm2-activation.service lvm2-lvmetad.service iscsi.service iscsid.service fcoe.service
+After=lvm2-activation.service lvm2-lvmetad.service iscsi-shutdown.service iscsi.service iscsid.service fcoe.service
 DefaultDependencies=no
 Conflicts=shutdown.target
 


