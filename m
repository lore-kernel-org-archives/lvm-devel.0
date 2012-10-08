From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon,  8 Oct 2012 14:53:17 +0000 (UTC)
Subject: master - systemd: remove ExecStartPost from lvm2-lvmetad.service.
Message-ID: <20121008145317.A5C822370@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7a64fff948278604d287ac96d9783a6b896de99b
Commit:        7a64fff948278604d287ac96d9783a6b896de99b
Parent:        ee4c75c8b790001cb05d85a44b2a894a91f4ba05
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Oct 8 16:49:54 2012 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Oct 8 16:49:54 2012 +0200

systemd: remove ExecStartPost from lvm2-lvmetad.service.

The ExecStartPost with pvscan --cache in lvm2-lvmetad.service
is not needed now as this is called transparently within the
first LVM command that queries lvmetad.
---
 WHATS_NEW                                       |    1 +
 scripts/lvm2_lvmetad_systemd_red_hat.service.in |    1 -
 2 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 004f8b1..cf1b563 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.98 -
 =================================
+  Remove ExecStartPost with pvscan --cache from lvm2-lvmetad.service.
   Report invalid percentage for property snap_percent of non-snaphot LVs.
   Disallow convertion of thins to mirrors.
   Fix lvm2api data_percent reporting for thin volumes.
diff --git a/scripts/lvm2_lvmetad_systemd_red_hat.service.in b/scripts/lvm2_lvmetad_systemd_red_hat.service.in
index e527369..0150726 100644
--- a/scripts/lvm2_lvmetad_systemd_red_hat.service.in
+++ b/scripts/lvm2_lvmetad_systemd_red_hat.service.in
@@ -10,7 +10,6 @@ Conflicts=shutdown.target
 Type=forking
 NonBlocking=true
 ExecStart=@sbindir@/lvmetad
-ExecStartPost=@sbindir@/lvm pvscan --cache
 ExecReload=@sbindir@/lvmetad -R
 Environment=SD_ACTIVATION=1
 Restart=on-abort


