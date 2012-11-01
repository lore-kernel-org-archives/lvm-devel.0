From: Ondrej Kozina <okozina@redhat.com>
Date: Thu,  1 Nov 2012 18:22:17 +0100
Subject: [PATCH 3/3] - alter related configuration files
In-Reply-To: <1351790537-10199-1-git-send-email-okozina@redhat.com>
References: <1351790537-10199-1-git-send-email-okozina@redhat.com>
Message-ID: <1351790537-10199-4-git-send-email-okozina@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

---
 configure.in        | 3 +++
 make.tmpl.in        | 1 +
 scripts/Makefile.in | 9 ++++++++-
 3 files changed, 12 insertions(+), 1 deletion(-)

diff --git a/configure.in b/configure.in
index 75e0d84..2fe0763 100644
--- a/configure.in
+++ b/configure.in
@@ -1658,7 +1658,10 @@ python/setup.py
 scripts/blkdeactivate.sh
 scripts/blk_availability_init_red_hat
 scripts/blk_availability_systemd_red_hat.service
+scripts/clvmd_activation_script_red_hat.sh
+scripts/clvmd_activation_systemd_red_hat.service
 scripts/clvmd_init_red_hat
+scripts/clvmd_systemd_red_hat.service
 scripts/cmirrord_init_red_hat
 scripts/lvm2_lvmetad_init_red_hat
 scripts/lvm2_lvmetad_systemd_red_hat.socket
diff --git a/make.tmpl.in b/make.tmpl.in
index 8b56f01..5102237 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -73,6 +73,7 @@ systemd_unit_dir = $(DESTDIR)@systemdsystemunitdir@
 systemd_generator_dir = $(DESTDIR)@systemdutildir@/system-generators
 tmpfiles_dir = $(DESTDIR)@tmpfilesdir@
 ocf_scriptdir = $(DESTDIR)@OCFDIR@
+libexecdir = $(DESTDIR)@libexecdir@
 
 USRLIB_RELPATH = $(shell echo $(abspath $(usrlibdir) $(libdir)) | \
   $(AWK) -f $(top_srcdir)/scripts/relpath.awk)
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 91e2e94..7f1f1cf 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -108,6 +108,12 @@ ifeq ("@BUILD_LVMETAD@", "yes")
 	$(INSTALL_DATA) lvm2_lvmetad_systemd_red_hat.socket $(systemd_unit_dir)/lvm2-lvmetad.socket
 	$(INSTALL_DATA) lvm2_lvmetad_systemd_red_hat.service $(systemd_unit_dir)/lvm2-lvmetad.service
 endif
+ifneq ("@CLVMD@", "none")
+	$(INSTALL_DATA) clvmd_systemd_red_hat.service $(systemd_unit_dir)/clvmd-daemon.service
+	$(INSTALL_DATA) clvmd_activation_systemd_red_hat.service $(systemd_unit_dir)/clvmd.service
+	$(INSTALL_DIR) $(libexecdir)/clvmd
+	$(INSTALL_DATA) clvmd_activation_script_red_hat.sh $(libexecdir)/clvmd/clvmd.sh
+endif
 
 install_tmpfiles_configuration:
 	$(INSTALL_DIR) $(tmpfiles_dir)
@@ -118,4 +124,5 @@ DISTCLEAN_TARGETS += clvmd_init_red_hat cmirrord_init_red_hat \
 		     dm_event_systemd_red_hat.socket dm_event_systemd_red_hat.service \
 		     lvm2_monitoring_systemd_red_hat.service \
 		     lvm2_lvmetad_systemd_red_hat.socket lvm2_lvmetad_systemd_red_hat.service \
-		     lvm2_tmpfiles_red_hat.conf
+		     lvm2_tmpfiles_red_hat.conf clvmd_systemd_red_hat.service \
+		     clvmd_activation_systemd_red_hat.service clvmd_activation_script_red_hat.sh
-- 
1.7.12.4


