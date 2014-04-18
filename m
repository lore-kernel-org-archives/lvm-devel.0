From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 18 Apr 2014 14:55:06 +0000 (UTC)
Subject: master - makefiles: clear targets in with make clean
Message-ID: <20140418145506.7F05060758@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1af05a7a166a470d1b9d86f88fdc64c2d984124b
Commit:        1af05a7a166a470d1b9d86f88fdc64c2d984124b
Parent:        4955dae4be6ca42f3428ca4f71ba86c3d0fb89b4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 17 10:01:05 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 18 16:38:48 2014 +0200

makefiles: clear targets in with make clean

Make clean usually cleans all compiled files.
Make distclean cleans configure generated files
---
 scripts/Makefile.in |   32 ++++++++++++++++++++------------
 1 files changed, 20 insertions(+), 12 deletions(-)

diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 8fdb5f7..ed77900 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -29,6 +29,7 @@ ifeq ("@APPLIB@", "yes")
 endif
 
 ifeq ("@DMEVENTD@", "yes")
+	DEPLIBS += $(top_builddir)/daemons/dmeventd/libdevmapper-event.so
 	LVMLIBS += -ldevmapper-event
 endif
 
@@ -124,15 +125,22 @@ install_tmpfiles_configuration:
 	$(INSTALL_DIR) $(tmpfiles_dir)
 	$(INSTALL_DATA) lvm2_tmpfiles_red_hat.conf $(tmpfiles_dir)/lvm2.conf
 
-DISTCLEAN_TARGETS += clvmd_init_red_hat cmirrord_init_red_hat \
-		     lvm2_monitoring_init_red_hat lvm2_lvmetad_init_red_hat \
-		     dm_event_systemd_red_hat.socket dm_event_systemd_red_hat.service \
-		     lvm2_monitoring_systemd_red_hat.service \
-		     lvm2_lvmetad_systemd_red_hat.socket lvm2_lvmetad_systemd_red_hat.service \
-		     lvm2_pvscan_systemd_red_hat at .service \
-		     lvm2_tmpfiles_red_hat.conf blk_availability_init_red_hat \
-		     blk_availability_systemd_red_hat.service \
-		     blkdeactivate.sh lvm2_clvmd_systemd_red_hat.service \
-		     lvm2_cmirrord_systemd_red_hat.service \
-		     lvm2_cluster_activation_systemd_red_hat.service \
-		     lvm2_cluster_activation_red_hat.sh
+CLEAN_TARGETS += \
+	blkdeactivate.sh \
+	blk_availability_init_red_hat \
+	blk_availability_systemd_red_hat.service \
+	clvmd_init_red_hat \
+	cmirrord_init_red_hat \
+	dm_event_systemd_red_hat.service \
+	dm_event_systemd_red_hat.socket \
+	lvm2_cluster_activation_red_hat.sh \
+	lvm2_cluster_activation_systemd_red_hat.service \
+	lvm2_clvmd_systemd_red_hat.service \
+	lvm2_cmirrord_systemd_red_hat.service \
+	lvm2_lvmetad_init_red_hat \
+	lvm2_lvmetad_systemd_red_hat.service \
+	lvm2_lvmetad_systemd_red_hat.socket \
+	lvm2_monitoring_init_red_hat \
+	lvm2_monitoring_systemd_red_hat.service \
+	lvm2_pvscan_systemd_red_hat at .service \
+	lvm2_tmpfiles_red_hat.conf


