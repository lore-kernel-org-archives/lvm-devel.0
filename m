From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sat, 22 Nov 2014 09:01:24 +0000 (UTC)
Subject: master - configure: fix CLVMD_PATH location
Message-ID: <20141122090124.5537660E11@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6ce8e579897929fceb9da7865160f2e7921ddc6a
Commit:        6ce8e579897929fceb9da7865160f2e7921ddc6a
Parent:        089bdc0be479dce8a886a50606b4bbb108614fb2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 21 16:33:48 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sat Nov 22 09:55:46 2014 +0100

configure: fix CLVMD_PATH location

Commit d2c116058e72d365802eb5641be60a615daacb96 introduced regression
with CLVMD_PATH.

+        CLVMD_PATH="$clvmd_prefix/sbin/clvmd"
         test "$prefix" != NONE && clvmd_prefix=$prefix

It has set CLVMD_PATH before clvmd_prefix got its final value.
Move it one line below.
---
 WHATS_NEW    |    1 +
 configure    |    2 +-
 configure.in |    2 +-
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 3ccb8dc..31a1f3e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.113 - 
 =====================================
+  Respect --prefix when setting CLMVD_PATH configure (2.02.89).
   Default to configure --enable-udev-systemd-background-jobs for systemd>=205.
   Fix ignore_vg() to properly react on various vg_read errors (2.02.112).
   Failed recovery returns FAILED_RECOVERY status flag for vg_read().
diff --git a/configure b/configure
index a2a094c..df902c3 100755
--- a/configure
+++ b/configure
@@ -12433,8 +12433,8 @@ _ACEOF
 
 if  test "$CLVMD" != none; then
 	clvmd_prefix=$ac_default_prefix
-	CLVMD_PATH="$clvmd_prefix/sbin/clvmd"
 	test "$prefix" != NONE && clvmd_prefix=$prefix
+	CLVMD_PATH="$clvmd_prefix/sbin/clvmd"
 
 cat >>confdefs.h <<_ACEOF
 #define CLVMD_PATH "$CLVMD_PATH"
diff --git a/configure.in b/configure.in
index d4e367d..5b22b93 100644
--- a/configure.in
+++ b/configure.in
@@ -1545,8 +1545,8 @@ AC_DEFINE_UNQUOTED(LVM_PATH, ["$LVM_PATH"], [Path to lvm binary.])
 
 if  test "$CLVMD" != none; then
 	clvmd_prefix=$ac_default_prefix
-	CLVMD_PATH="$clvmd_prefix/sbin/clvmd"
 	test "$prefix" != NONE && clvmd_prefix=$prefix
+	CLVMD_PATH="$clvmd_prefix/sbin/clvmd"
 	AC_DEFINE_UNQUOTED(CLVMD_PATH, ["$CLVMD_PATH"], [Path to clvmd binary.])
 fi
 


