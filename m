From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 27 Sep 2016 08:50:54 +0000 (UTC)
Subject: master - systemd: disable service start rate limiting for lvm2-pvscan@.service
Message-ID: <20160927085054.D4D1960C3A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0a480c5c52bd34a1eb8337d59a7f4cc60317d2b1
Commit:        0a480c5c52bd34a1eb8337d59a7f4cc60317d2b1
Parent:        397c246fe03876fb6c68cece2d4345e0fd0ca2e3
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Sep 27 10:47:54 2016 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Sep 27 10:48:01 2016 +0200

systemd: disable service start rate limiting for lvm2-pvscan at .service

We shouldn't be losing pvscans just because of the fact that the
underlying device (PV) appears and disappears quickly in the system,
otherwise lvmetad may not see the device if it appears again (or it may
still keep the device in cache even it's already gone).
---
 WHATS_NEW                                       |    1 +
 scripts/lvm2_pvscan_systemd_red_hat at .service.in |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4346de7..aa6c0c6 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.167 - 
 ======================================
+  Disable systemd service start rate limiting for lvm2-pvscan at .service.
 
 Version 2.02.166 - 26th September 2016
 ======================================
diff --git a/scripts/lvm2_pvscan_systemd_red_hat at .service.in b/scripts/lvm2_pvscan_systemd_red_hat at .service.in
index 03651d5..0989590 100644
--- a/scripts/lvm2_pvscan_systemd_red_hat at .service.in
+++ b/scripts/lvm2_pvscan_systemd_red_hat at .service.in
@@ -2,6 +2,7 @@
 Description=LVM2 PV scan on device %i
 Documentation=man:pvscan(8)
 DefaultDependencies=no
+StartLimitInterval=0
 BindsTo=dev-block-%i.device
 Requires=lvm2-lvmetad.socket
 After=lvm2-lvmetad.socket lvm2-lvmetad.service


