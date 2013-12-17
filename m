From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 17 Dec 2013 09:40:47 +0000 (UTC)
Subject: master - systemd: make sure lvm2-lvmetad.socket is available for lvm2-pvscan@.service
Message-ID: <20131217094047.232D860F72@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a8b5dce997b26ff10892aab83646b65c1146f576
Commit:        a8b5dce997b26ff10892aab83646b65c1146f576
Parent:        56af6cae087259f620a356a6706ea10249015069
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Dec 17 10:40:32 2013 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Dec 17 10:40:32 2013 +0100

systemd: make sure lvm2-lvmetad.socket is available for lvm2-pvscan at .service

---
 scripts/lvm2_pvscan_systemd_red_hat at .service.in |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/scripts/lvm2_pvscan_systemd_red_hat at .service.in b/scripts/lvm2_pvscan_systemd_red_hat at .service.in
index 4225982..6b21c75 100644
--- a/scripts/lvm2_pvscan_systemd_red_hat at .service.in
+++ b/scripts/lvm2_pvscan_systemd_red_hat at .service.in
@@ -3,6 +3,7 @@ Description=LVM2 PV scan on device %i
 Documentation=man:pvscan(8)
 DefaultDependencies=no
 BindsTo=dev-block-%i.device
+Requires=lvm2-lvmetad.socket
 After=lvm2-lvmetad.socket
 Before=shutdown.target
 Conflicts=shutdown.target


