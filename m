From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 30 Apr 2014 13:21:48 +0000 (UTC)
Subject: master - systemd: use lvm binary insetad of command symlink in lvm2-pvscan.service
Message-ID: <20140430132148.1C52F609C8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=239ba5bb04deccee83aa603efee11a9670f6f3fe
Commit:        239ba5bb04deccee83aa603efee11a9670f6f3fe
Parent:        81b096af34283cf91205b0e63f598ca92d625051
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Apr 30 15:21:25 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Apr 30 15:21:25 2014 +0200

systemd: use lvm binary insetad of command symlink in lvm2-pvscan.service

---
 scripts/lvm2_pvscan_systemd_red_hat at .service.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/scripts/lvm2_pvscan_systemd_red_hat at .service.in b/scripts/lvm2_pvscan_systemd_red_hat at .service.in
index cdbbe40..7d3b291 100644
--- a/scripts/lvm2_pvscan_systemd_red_hat at .service.in
+++ b/scripts/lvm2_pvscan_systemd_red_hat at .service.in
@@ -11,5 +11,5 @@ Conflicts=shutdown.target
 [Service]
 Type=oneshot
 RemainAfterExit=yes
-ExecStart=@sbindir@/pvscan --cache --activate ay %i
-ExecStop=@sbindir@/pvscan --cache %i
+ExecStart=@sbindir@/lvm pvscan --cache --activate ay %i
+ExecStop=@sbindir@/lvm pvscan --cache %i


