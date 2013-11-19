From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 19 Nov 2013 09:56:01 +0000 (UTC)
Subject: master - Makefile: fix build in non src dir
Message-ID: <20131119095601.12DBB610A5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c697f501c7d9f29b6e0b32225b962d1632654004
Commit:        c697f501c7d9f29b6e0b32225b962d1632654004
Parent:        3a6f91d7139119bea664050a957cbc21490398bc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 15 23:44:18 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Nov 19 10:55:11 2013 +0100

Makefile: fix build in non src dir

Fix 'make install' from builddir != srcdir.
---
 WHATS_NEW        |    1 +
 conf/Makefile.in |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 0a4909a..bd18c6f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Fix install of conf subdir when not building in srcdir.
   Add reporting of thin_id device id for thin volumes.
   Fix reporting of empty numerical values.
   Simplify reporting code.
diff --git a/conf/Makefile.in b/conf/Makefile.in
index 8b5238a..3f66621 100644
--- a/conf/Makefile.in
+++ b/conf/Makefile.in
@@ -19,7 +19,7 @@ CONFSRC=example.conf
 CONFDEST=lvm.conf
 
 DEFAULT_PROFILE=default.profile
-PROFILES=$(DEFAULT_PROFILE) thin-performance.profile
+PROFILES=$(DEFAULT_PROFILE) $(srcdir)/thin-performance.profile
 
 include $(top_builddir)/make.tmpl
 


