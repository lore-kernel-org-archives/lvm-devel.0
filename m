From: Joe Thornber <thornber@sourceware.org>
Date: Mon, 4 Jun 2018 05:01:22 -0400
Subject: master - build: link lvm2_activation_generator_systemd_red_hat with libdevice-mapper.a
Message-ID: <201806040901.w5491Mea019243@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=21a5be2364574de43e2afe55a250ccced02df008
Commit:        21a5be2364574de43e2afe55a250ccced02df008
Parent:        6a1f458bb7a95b5cf71e4e8bf9d030ce739ab039
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Mon Jun 4 10:00:44 2018 +0100
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Mon Jun 4 10:00:44 2018 +0100

build: link lvm2_activation_generator_systemd_red_hat with libdevice-mapper.a

---
 scripts/Makefile.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index eeac881..194d2e2 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -88,8 +88,8 @@ endif
 
 CFLAGS_lvm2_activation_generator_systemd_red_hat.o += $(EXTRA_EXEC_CFLAGS)
 
-lvm2_activation_generator_systemd_red_hat: $(OBJECTS) $(DEPLIBS)
-	$(CC) -o $@ $(OBJECTS) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) $(LVMLIBS)
+lvm2_activation_generator_systemd_red_hat: $(OBJECTS) $(DEPLIBS) $(top_builddir)/device_mapper/libdevice-mapper.a
+	$(CC) -o $@ $(OBJECTS) $(CFLAGS) $(LDFLAGS) $(EXTRA_EXEC_LDFLAGS) $(ELDFLAGS) $(LVMLIBS) $(top_builddir)/device_mapper/libdevice-mapper.a $(LIBS)
 
 install_systemd_generators:
 	$(INSTALL_DIR) $(systemd_generator_dir)


