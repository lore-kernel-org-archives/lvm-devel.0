From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Jun 2018 18:49:18 -0400
Subject: master - scripts: clvmd gone
Message-ID: <201806142249.w5EMnIEm023452@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7d8bd97187b5eb8bbea10d95bc62b4a14c5e4d4e
Commit:        7d8bd97187b5eb8bbea10d95bc62b4a14c5e4d4e
Parent:        9d2b9e5bc6a5a887ab4423caabb4ec43031de662
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Jun 15 00:46:24 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 15 00:46:24 2018 +0200

scripts: clvmd gone

---
 scripts/Makefile.in |    8 --------
 1 files changed, 0 insertions(+), 8 deletions(-)

diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index f0addc3..fc97544 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -69,9 +69,6 @@ endif
 ifeq ("@BUILD_LVMPOLLD@", "yes")
 	$(INSTALL_SCRIPT) lvm2_lvmpolld_init_red_hat $(initdir)/lvm2-lvmpolld
 endif
-ifneq ("@CLVMD@", "none")
-	$(INSTALL_SCRIPT) clvmd_init_red_hat $(initdir)/clvmd
-endif
 ifeq ("@BUILD_CMIRRORD@", "yes")
 	$(INSTALL_SCRIPT) cmirrord_init_red_hat $(initdir)/cmirrord
 endif
@@ -110,11 +107,6 @@ endif
 ifeq ("@BUILD_LVMLOCKD@", "yes")
 	$(INSTALL_DATA) lvm2_lvmlockd_systemd_red_hat.service $(systemd_unit_dir)/lvm2-lvmlockd.service
 endif
-ifneq ("@CLVMD@", "none")
-	$(INSTALL_DATA) lvm2_clvmd_systemd_red_hat.service $(systemd_unit_dir)/lvm2-clvmd.service
-	$(INSTALL_DATA) lvm2_cluster_activation_systemd_red_hat.service $(systemd_unit_dir)/lvm2-cluster-activation.service
-	$(INSTALL_SCRIPT) lvm2_cluster_activation_red_hat.sh $(systemd_dir)/lvm2-cluster-activation
-endif
 ifeq ("@BUILD_CMIRRORD@", "yes")
 	$(INSTALL_DATA) lvm2_cmirrord_systemd_red_hat.service $(systemd_unit_dir)/lvm2-cmirrord.service
 endif


