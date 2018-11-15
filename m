From: David Teigland <teigland@sourceware.org>
Date: Thu, 15 Nov 2018 10:26:22 -0500
Subject: master - scripts: remove lvmetad from makefile
Message-ID: <201811151526.wAFFQMeO019769@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d44bfe90f1b609d23566ba26c4d51ba167f2368d
Commit:        d44bfe90f1b609d23566ba26c4d51ba167f2368d
Parent:        df2fa88e631b13f0f2cfff4aeab80f12bd93ab72
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Thu Nov 15 09:25:55 2018 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Thu Nov 15 09:25:55 2018 -0600

scripts: remove lvmetad from makefile

---
 scripts/Makefile.in |   11 -----------
 1 files changed, 0 insertions(+), 11 deletions(-)

diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 039cac2..27fc201 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -63,9 +63,6 @@ install_initscripts:
 ifeq ("@BUILD_DMEVENTD@", "yes")
 	$(INSTALL_SCRIPT) lvm2_monitoring_init_red_hat $(initdir)/lvm2-monitor
 endif
-ifeq ("@BUILD_LVMETAD@", "yes")
-	$(INSTALL_SCRIPT) lvm2_lvmetad_init_red_hat $(initdir)/lvm2-lvmetad
-endif
 ifeq ("@BUILD_LVMPOLLD@", "yes")
 	$(INSTALL_SCRIPT) lvm2_lvmpolld_init_red_hat $(initdir)/lvm2-lvmpolld
 endif
@@ -95,11 +92,6 @@ endif
 ifeq ("@BLKDEACTIVATE@", "yes")
 	$(INSTALL_DATA) blk_availability_systemd_red_hat.service $(systemd_unit_dir)/blk-availability.service
 endif
-ifeq ("@BUILD_LVMETAD@", "yes")
-	$(INSTALL_DATA) lvm2_lvmetad_systemd_red_hat.socket $(systemd_unit_dir)/lvm2-lvmetad.socket
-	$(INSTALL_DATA) lvm2_lvmetad_systemd_red_hat.service $(systemd_unit_dir)/lvm2-lvmetad.service
-	$(INSTALL_DATA) lvm2_pvscan_systemd_red_hat at .service $(systemd_unit_dir)/lvm2-pvscan at .service
-endif
 ifeq ("@BUILD_LVMPOLLD@", "yes")
 	$(INSTALL_DATA) lvm2_lvmpolld_systemd_red_hat.socket $(systemd_unit_dir)/lvm2-lvmpolld.socket
 	$(INSTALL_DATA) lvm2_lvmpolld_systemd_red_hat.service $(systemd_unit_dir)/lvm2-lvmpolld.service
@@ -144,10 +136,7 @@ DISTCLEAN_TARGETS += \
 	lvm2_clvmd_systemd_red_hat.service \
 	lvm2_cmirrord_systemd_red_hat.service \
 	lvm2_lvmdbusd_systemd_red_hat.service \
-	lvm2_lvmetad_init_red_hat \
 	lvm2_lvmpolld_init_red_hat \
-	lvm2_lvmetad_systemd_red_hat.service \
-	lvm2_lvmetad_systemd_red_hat.socket \
 	lvm2_lvmpolld_systemd_red_hat.service \
 	lvm2_lvmpolld_systemd_red_hat.socket \
 	lvmlockd.service \


