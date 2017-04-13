From: Alasdair Kergon <agk@sourceware.org>
Date: Wed, 12 Apr 2017 21:21:03 -0400
Subject: master - conf: Add missing prefix to installation directory.
Message-ID: <201704130121.v3D1L3TV020266@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4547218a7dcee0508f61561e3e319428651e8951
Commit:        4547218a7dcee0508f61561e3e319428651e8951
Parent:        ae7f696d535143be88aa8aa564fad9c1851cebd9
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Apr 13 02:17:27 2017 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Apr 13 02:17:27 2017 +0100

conf: Add missing prefix to installation directory.

Our Makefiles also support systems that set the installation prefix
at configuration time - the use of DESTDIR is not required.
---
 WHATS_NEW        |    1 +
 conf/Makefile.in |    4 ++--
 make.tmpl.in     |    3 ++-
 3 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 766bf32..56ad0ca 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.171 - 
 ==================================
+  Add missing configurable prefix to configuration file installation directory.
 
 Version 2.02.170 - 13th April 2017
 ==================================
diff --git a/conf/Makefile.in b/conf/Makefile.in
index db8e99f..c8fee3e 100644
--- a/conf/Makefile.in
+++ b/conf/Makefile.in
@@ -48,8 +48,8 @@ install_localconf: $(CONFLOCAL)
 	fi
 
 install_profiles: $(PROFILES)
-	$(INSTALL_DIR) $(DESTDIR)$(DEFAULT_PROFILE_DIR)
-	$(INSTALL_DATA) $(PROFILES) $(DESTDIR)$(DEFAULT_PROFILE_DIR)/
+	$(INSTALL_DIR) $(profiledir)
+	$(INSTALL_DATA) $(PROFILES) $(profiledir)/
 
 install_lvm2: install_conf install_localconf install_profiles
 
diff --git a/make.tmpl.in b/make.tmpl.in
index 8148fb5..c3e6c8c 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -82,7 +82,8 @@ udev_prefix = @udev_prefix@
 sysconfdir = @sysconfdir@
 rootdir = $(DESTDIR)/
 bindir = $(DESTDIR)@bindir@
-confdir = $(DESTDIR)@CONFDIR@/lvm
+confdir = $(DESTDIR)$(exec_prefix)@CONFDIR@/lvm
+profiledir = $(confdir)/@DEFAULT_PROFILE_SUBDIR@
 includedir = $(DESTDIR)@includedir@
 libdir = $(DESTDIR)@libdir@
 libexecdir = $(DESTDIR)@libexecdir@


