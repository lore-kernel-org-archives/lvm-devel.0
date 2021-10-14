From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 14 Oct 2021 22:33:08 +0000 (GMT)
Subject: main - configure: bash var typo
Message-ID: <20211014223308.291033858419@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=52a52d556773cf57007932ed483d20d21bd53823
Commit:        52a52d556773cf57007932ed483d20d21bd53823
Parent:        04725763a1eb20565cc66e1fd009d9ee93220524
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 15 00:32:36 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 15 00:32:36 2021 +0200

configure: bash var typo

---
 configure    | 2 +-
 configure.ac | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/configure b/configure
index 7f55569b0..808029a79 100755
--- a/configure
+++ b/configure
@@ -11646,7 +11646,7 @@ $as_echo "#define APP_MACHINEID_SUPPORT 1" >>confdefs.h
       SYSTEMD_MIN_VERSION=234
 fi
 
-if test -n "SYSTEMD_MIN_VERSION"; then :
+if test -n "$SYSTEMD_MIN_VERSION"; then :
 
       pkg_config_init
 
diff --git a/configure.ac b/configure.ac
index 0ec8d6b7d..ea56aa838 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1145,7 +1145,7 @@ AS_IF([test "$APP_MACHINEID_SUPPORT" = yes],
       SYSTEMD_MIN_VERSION=234)
 
 dnl -- Look for libsystemd libraries
-AS_IF([test -n "SYSTEMD_MIN_VERSION"],[
+AS_IF([test -n "$SYSTEMD_MIN_VERSION"],[
       pkg_config_init
       PKG_CHECK_MODULES(SYSTEMD, systemd >= "$SYSTEMD_MIN_VERSION", [], $bailout)
       SYSTEMD_LIBS="-lsystemd"])


