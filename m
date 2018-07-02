From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 2 Jul 2018 04:26:47 -0400
Subject: master - build: drop some more old files
Message-ID: <201807020826.w628Ql1u025644@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=b55d30956d77afec7a985132225d5b64d072b598
Commit:        b55d30956d77afec7a985132225d5b64d072b598
Parent:        52b07672f867a4ec695ab1eff277f0a7f7d88087
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Jul 1 15:01:41 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jul 2 10:21:42 2018 +0200

build: drop some more old files

---
 include/Makefile.in |    2 ++
 scripts/Makefile.in |    4 ++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/include/Makefile.in b/include/Makefile.in
index efe263c..7993998 100644
--- a/include/Makefile.in
+++ b/include/Makefile.in
@@ -20,6 +20,8 @@ include $(top_builddir)/make.tmpl
 
 DISTCLEAN_TARGETS += .configure.h lvm-version.h
 CLEAN_TARGETS += \
+ .symlinks \
+ .symlinks_created \
  activate.h \
  archiver.h \
  bcache.h \
diff --git a/scripts/Makefile.in b/scripts/Makefile.in
index fc97544..6d32b63 100644
--- a/scripts/Makefile.in
+++ b/scripts/Makefile.in
@@ -154,3 +154,7 @@ DISTCLEAN_TARGETS += \
 	lvm2_monitoring_systemd_red_hat.service \
 	lvm2_pvscan_systemd_red_hat at .service \
 	lvm2_tmpfiles_red_hat.conf
+
+# Remove ancient files
+DISTCLEAN_TARGETS += \
+	lvm2_lvmlocking_systemd_red_hat.service


