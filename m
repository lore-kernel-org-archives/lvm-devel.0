From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue,  2 Nov 2010 15:10:42 +0100
Subject: [PATCH 2/3] Add ${prefix}
In-Reply-To: <cover.1288706876.git.zkabelac@redhat.com>
References: <cover.1288706876.git.zkabelac@redhat.com>
Message-ID: <e9744c088379445ee05a3db39fa75f03b771ad2f.1288706876.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Avoid files to be written into the live system if lvm was
configured with diferent --prefix.
Also put path into one variable initd_dir.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 scripts/Makefile.in |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index 2220b9c..d859564 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -14,6 +14,7 @@
 srcdir = @srcdir@
 top_srcdir = @top_srcdir@
 top_builddir = @top_builddir@
+initd_dir = $(DESTDIR)${prefix}/etc/rc.d/init.d
 
 include $(top_builddir)/make.tmpl
 
@@ -33,13 +34,13 @@ install: install_lvm2
 
 # FIXME Customise for other distributions
 install_initscripts:
-	$(INSTALL_DIR) $(DESTDIR)/etc/rc.d/init.d
-	$(INSTALL_SCRIPT) lvm2_monitoring_init_red_hat $(DESTDIR)/etc/rc.d/init.d/lvm2-monitor
+	$(INSTALL_DIR) $(initd_dir)
+	$(INSTALL_SCRIPT) lvm2_monitoring_init_red_hat $(initd_dir)/lvm2-monitor
 ifneq ("@CLVMD@", "none")
-	$(INSTALL_SCRIPT) clvmd_init_red_hat $(DESTDIR)/etc/rc.d/init.d/clvmd
+	$(INSTALL_SCRIPT) clvmd_init_red_hat $(initd_dir)/clvmd
 endif
 ifeq ("@BUILD_CMIRRORD@", "yes")
-	$(INSTALL_SCRIPT) cmirrord_init_red_hat $(DESTDIR)/etc/rc.d/init.d/cmirrord
+	$(INSTALL_SCRIPT) cmirrord_init_red_hat $(initd_dir)/cmirrord
 endif
 
 DISTCLEAN_TARGETS += clvmd_init_red_hat cmirrord_init_red_hat lvm2_monitoring_init_red_hat
-- 
1.7.3.2


