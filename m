From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 26 Jul 2012 09:35:48 +0000 (UTC)
Subject: master - systemd: ensure monitoring is handled after lvmetad
Message-ID: <20120726093548.13B6E23EE@lists.fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9161308252336491a107983ed16481e446853e26
Commit:        9161308252336491a107983ed16481e446853e26
Parent:        e0bc3cf1a0102aff6c047a3293ef45ca5f221c10
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 26 11:30:27 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jul 26 11:30:27 2012 +0200

systemd: ensure monitoring is handled after lvmetad

Monitoring is handled using "vgchange --monitor" call. Ensure that lvmetad is up
and running at the time of this call to prevent any fallback to direct scan
within the vgchange. The same applies for shutdown sequence but the other way
round - switch monitoring off and lvmetad afterwards.
---
 scripts/lvm2_monitoring_systemd_red_hat.service.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/lvm2_monitoring_systemd_red_hat.service.in b/scripts/lvm2_monitoring_systemd_red_hat.service.in
index a8d5183..425cb0d 100644
--- a/scripts/lvm2_monitoring_systemd_red_hat.service.in
+++ b/scripts/lvm2_monitoring_systemd_red_hat.service.in
@@ -2,7 +2,7 @@
 Description=Monitoring of LVM2 mirrors, snapshots etc. using dmeventd or progress polling
 Documentation=man:dmeventd(8) man:lvcreate(8) man:lvchange(8) man:vgchange(8)
 Requires=dm-event.socket
-After=dm-event.socket fedora-storage-init.service fedora-storage-init-late.service
+After=dm-event.socket fedora-storage-init.service fedora-storage-init-late.service lvm2-lvmetad.service
 Before=local-fs.target
 DefaultDependencies=no
 Conflicts=shutdown.target


