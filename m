From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 19 Apr 2021 13:00:49 +0000 (GMT)
Subject: main - man: with internal build install cache, thin, vdo
Message-ID: <20210419130049.58AC0396901B@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=679116a9b859888a893de83236a8966063046f2b
Commit:        679116a9b859888a893de83236a8966063046f2b
Parent:        dc934b13b9e47e59f0a176c9f4d9ceaa8a11ca32
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Apr 19 11:24:16 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Apr 19 14:37:08 2021 +0200

man: with internal build install cache, thin, vdo

Do not install .7 man pages when building --without internal segtype
support for types: cache, thin, vdo.
---
 configure       |  4 ++++
 configure.ac    |  2 ++
 man/Makefile.in | 22 ++++++++++++++++++++--
 3 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/configure b/configure
index 95c1d2758..7c6bd48d2 100755
--- a/configure
+++ b/configure
@@ -640,6 +640,7 @@ LVMLOCKD_PIDFILE
 LVMPOLLD_PIDFILE
 DMEVENTD_PIDFILE
 WRITE_INSTALL
+WRITECACHE
 VDO_LIB
 VDO_INCLUDE
 VDO
@@ -702,6 +703,7 @@ LIB_SUFFIX
 LDDEPS
 JOBS
 INTL
+INTEGRITY
 HAVE_VALGRIND
 HAVE_REALTIME
 HAVE_LIBDL
@@ -14173,6 +14175,8 @@ _ACEOF
 
 
 
+
+
 
 
 
diff --git a/configure.ac b/configure.ac
index 33a691e01..1a49e7fe7 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1808,6 +1808,7 @@ AC_SUBST(BLKDEACTIVATE)
 AC_SUBST(HAVE_LIBDL)
 AC_SUBST(HAVE_REALTIME)
 AC_SUBST(HAVE_VALGRIND)
+AC_SUBST(INTEGRITY)
 AC_SUBST(INTL)
 AC_SUBST(JOBS)
 AC_SUBST(LDDEPS)
@@ -1884,6 +1885,7 @@ AC_SUBST(VDO)
 AC_SUBST(VDO_FORMAT_CMD)
 AC_SUBST(VDO_INCLUDE)
 AC_SUBST(VDO_LIB)
+AC_SUBST(WRITECACHE)
 AC_SUBST(WRITE_INSTALL)
 AC_SUBST(DMEVENTD_PIDFILE)
 AC_SUBST(LVMPOLLD_PIDFILE)
diff --git a/man/Makefile.in b/man/Makefile.in
index 31a4052e2..7f4664b01 100644
--- a/man/Makefile.in
+++ b/man/Makefile.in
@@ -32,8 +32,8 @@ CMIRRORDMAN = cmirrord.8
 LVMDBUSDMAN = lvmdbusd.8
 
 MAN5=lvm.conf.5
-MAN7=lvmsystemid.7 lvmreport.7 \
-     lvmcache.7 lvmraid.7 lvmthin.7 lvmvdo.7
+MAN7=lvmsystemid.7 lvmreport.7 lvmraid.7
+
 MAN8=lvm.8 lvmdump.8 lvm-fullreport.8 lvm-lvpoll.8 \
      lvcreate.8 lvchange.8 lvmconfig.8 lvconvert.8 lvdisplay.8 \
      lvextend.8 lvreduce.8 lvremove.8 lvrename.8 lvresize.8 lvs.8 \
@@ -49,6 +49,7 @@ MAN8CLUSTER=
 MAN8SYSTEMD_GENERATORS=lvm2-activation-generator.8
 
 ifeq (,$(findstring $(MAKECMDGOALS), distclean all_man install_all_man))
+  MAN7 += lvmcache.7 lvmthin.7 lvmvdo.7
   MAN8+=$(FSADMMAN) $(LVMPOLLDMAN) $(LVMLOCKDMAN) $(LVMDBUSDMAN)
   MAN8DM+=$(BLKDEACTIVATEMAN) $(DMEVENTDMAN) $(DMFILEMAPDMAN)
   MAN8CLUSTER+=$(CMIRRORDMAN)
@@ -84,6 +85,23 @@ else
   ifeq ("@BUILD_CMIRRORD@", "yes")
     MAN8CLUSTER+=$(CMIRRORDMAN)
   endif
+
+  ifeq ("@CACHE@", "internal")
+    MAN7 += lvmcache.7
+  else
+    ifeq ("@WRITECACHE@", "internal")
+      MAN7 += lvmcache.7
+    endif
+  endif
+
+  ifeq ("@THIN@", "internal")
+    MAN7 += lvmthin.7
+  endif
+
+  ifeq ("@VDO@", "internal")
+    MAN7 += lvmvdo.7
+  endif
+
 endif
 
 MAN5DIR=$(mandir)/man5


