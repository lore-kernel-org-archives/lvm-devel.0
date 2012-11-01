From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  1 Nov 2012 12:35:26 +0000 (UTC)
Subject: master - systemd: do not remove lvm2-activation.service
Message-ID: <20121101123526.96F6BA2C15@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=aa07de5a50175a2cee3f8662a23544d43feaf128
Commit:        aa07de5a50175a2cee3f8662a23544d43feaf128
Parent:        360c569ce8f0bfe936d59ca91de2716958550524
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Nov 1 13:33:49 2012 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Nov 1 13:33:49 2012 +0100

systemd: do not remove lvm2-activation.service

Fix previous commit 360c569ce8f0bfe936d59ca91de2716958550524.
Remove only fedora-storage-init/fedora-storage-init-late.service, but
not lvm2-activation.service.
fedora-storage-init.service fedora-storage-init-late.service
---
 scripts/lvm2_monitoring_systemd_red_hat.service.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/lvm2_monitoring_systemd_red_hat.service.in b/scripts/lvm2_monitoring_systemd_red_hat.service.in
index e6b4814..3cb998b 100644
--- a/scripts/lvm2_monitoring_systemd_red_hat.service.in
+++ b/scripts/lvm2_monitoring_systemd_red_hat.service.in
@@ -2,7 +2,7 @@
 Description=Monitoring of LVM2 mirrors, snapshots etc. using dmeventd or progress polling
 Documentation=man:dmeventd(8) man:lvcreate(8) man:lvchange(8) man:vgchange(8)
 Requires=dm-event.socket lvm2-lvmetad.socket
-After=dm-event.socket lvm2-lvmetad.socket lvm2-lvmetad.service
+After=dm-event.socket lvm2-lvmetad.socket lvm2-activation.service lvm2-lvmetad.service
 Before=local-fs.target
 DefaultDependencies=no
 Conflicts=shutdown.target


