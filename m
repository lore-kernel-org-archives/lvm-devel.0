From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 31 Mar 2015 13:51:42 +0000 (UTC)
Subject: master - systemd: stop lvm2-monitor.service before dm-event.service
Message-ID: <20150331135142.BFEF160F24@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=20c6192fbb9901468fad8fe41c7a6366aa3ab6fd
Commit:        20c6192fbb9901468fad8fe41c7a6366aa3ab6fd
Parent:        666738d57a6e6b4005030995a9641933c1a54e9d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Mar 31 15:50:16 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Mar 31 15:50:16 2015 +0200

systemd: stop lvm2-monitor.service before dm-event.service

---
 scripts/lvm2_monitoring_systemd_red_hat.service.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/lvm2_monitoring_systemd_red_hat.service.in b/scripts/lvm2_monitoring_systemd_red_hat.service.in
index bb52f0d..6aacdc2 100644
--- a/scripts/lvm2_monitoring_systemd_red_hat.service.in
+++ b/scripts/lvm2_monitoring_systemd_red_hat.service.in
@@ -2,7 +2,7 @@
 Description=Monitoring of LVM2 mirrors, snapshots etc. using dmeventd or progress polling
 Documentation=man:dmeventd(8) man:lvcreate(8) man:lvchange(8) man:vgchange(8)
 Requires=dm-event.socket lvm2-lvmetad.socket
-After=dm-event.socket lvm2-lvmetad.socket lvm2-activation.service lvm2-lvmetad.service
+After=dm-event.socket dm-event.service lvm2-lvmetad.socket lvm2-activation.service lvm2-lvmetad.service
 Before=local-fs.target
 DefaultDependencies=no
 Conflicts=shutdown.target


