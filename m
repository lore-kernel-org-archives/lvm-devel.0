From: David Teigland <teigland@sourceware.org>
Date: Wed, 13 Jun 2018 16:04:40 -0400
Subject: master - Remove makefile entries for removed script
Message-ID: <201806132004.w5DK4elB021047@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9b79f0244a17c91d790e2114e1c912e5efe00a2f
Commit:        9b79f0244a17c91d790e2114e1c912e5efe00a2f
Parent:        fa00fce97c1eabef9f1ec88dd420660cd4d6f004
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 13 15:02:12 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 13 15:04:26 2018 -0500

Remove makefile entries for removed script

---
 configure.ac        |    1 -
 scripts/.gitignore  |    1 -
 scripts/Makefile.in |    2 --
 3 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/configure.ac b/configure.ac
index 7d490f6..4c431e4 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1804,7 +1804,6 @@ scripts/lvm2_lvmpolld_init_red_hat
 scripts/lvm2_lvmpolld_systemd_red_hat.service
 scripts/lvm2_lvmpolld_systemd_red_hat.socket
 scripts/lvm2_lvmlockd_systemd_red_hat.service
-scripts/lvm2_lvmlocking_systemd_red_hat.service
 scripts/lvm2_monitoring_init_red_hat
 scripts/lvm2_monitoring_systemd_red_hat.service
 scripts/lvm2_pvscan_systemd_red_hat at .service
diff --git a/scripts/.gitignore b/scripts/.gitignore
index 0368f23..314bdb5 100644
--- a/scripts/.gitignore
+++ b/scripts/.gitignore
@@ -16,7 +16,6 @@ lvm2_lvmetad_init_red_hat
 lvm2_lvmetad_systemd_red_hat.service
 lvm2_lvmetad_systemd_red_hat.socket
 lvm2_lvmlockd_systemd_red_hat.service
-lvm2_lvmlocking_systemd_red_hat.service
 lvm2_lvmpolld_init_red_hat
 lvm2_lvmpolld_systemd_red_hat.service
 lvm2_lvmpolld_systemd_red_hat.socket
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 208aebf..f0addc3 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -109,7 +109,6 @@ ifeq ("@BUILD_LVMPOLLD@", "yes")
 endif
 ifeq ("@BUILD_LVMLOCKD@", "yes")
 	$(INSTALL_DATA) lvm2_lvmlockd_systemd_red_hat.service $(systemd_unit_dir)/lvm2-lvmlockd.service
-	$(INSTALL_DATA) lvm2_lvmlocking_systemd_red_hat.service $(systemd_unit_dir)/lvm2-lvmlocking.service
 endif
 ifneq ("@CLVMD@", "none")
 	$(INSTALL_DATA) lvm2_clvmd_systemd_red_hat.service $(systemd_unit_dir)/lvm2-clvmd.service
@@ -159,7 +158,6 @@ DISTCLEAN_TARGETS += \
 	lvm2_lvmpolld_systemd_red_hat.service \
 	lvm2_lvmpolld_systemd_red_hat.socket \
 	lvm2_lvmlockd_systemd_red_hat.service \
-	lvm2_lvmlocking_systemd_red_hat.service \
 	lvm2_monitoring_init_red_hat \
 	lvm2_monitoring_systemd_red_hat.service \
 	lvm2_pvscan_systemd_red_hat at .service \


