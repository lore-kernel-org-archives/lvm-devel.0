From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 21 May 2014 07:45:42 +0000 (UTC)
Subject: master - systemd: install lvm2-cluster-activation script as executable
Message-ID: <20140521074542.2CA6460756@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7d7c1f2025e73e729e53ddb9e09ce8097b532797
Commit:        7d7c1f2025e73e729e53ddb9e09ce8097b532797
Parent:        b57b4db88940566cb7df9368eb5520ebab1634a2
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed May 21 09:45:29 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed May 21 09:45:29 2014 +0200

systemd: install lvm2-cluster-activation script as executable

---
 scripts/Makefile.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 2c92033..19fd5d8 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -115,7 +115,7 @@ endif
 ifneq ("@CLVMD@", "none")
 	$(INSTALL_DATA) lvm2_clvmd_systemd_red_hat.service $(systemd_unit_dir)/lvm2-clvmd.service
 	$(INSTALL_DATA) lvm2_cluster_activation_systemd_red_hat.service $(systemd_unit_dir)/lvm2-cluster-activation.service
-	$(INSTALL_DATA) lvm2_cluster_activation_red_hat.sh $(systemd_dir)/lvm2-cluster-activation
+	$(INSTALL_SCRIPT) lvm2_cluster_activation_red_hat.sh $(systemd_dir)/lvm2-cluster-activation
 endif
 ifeq ("@BUILD_CMIRRORD@", "yes")
 	$(INSTALL_DATA) lvm2_cmirrord_systemd_red_hat.service $(systemd_unit_dir)/lvm2-cmirrord.service


