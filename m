From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Thu, 30 Aug 2018 07:16:25 -0400
Subject: master - configure: fix LVMCONFIG_PATH assignment
Message-ID: <201808301116.w7UBGPYP012961@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a0f6f188416823c2d32bb54bddff00e09f4426e4
Commit:        a0f6f188416823c2d32bb54bddff00e09f4426e4
Parent:        03ed2aae3a54afcc521a1af9b8a62827c1fb76d6
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Aug 30 12:59:59 2018 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Aug 30 13:14:10 2018 +0200

configure: fix LVMCONFIG_PATH assignment

---
 configure    |    2 +-
 configure.ac |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/configure b/configure
index 4ad2d4d..d6ddbc2 100755
--- a/configure
+++ b/configure
@@ -13417,7 +13417,7 @@ cat >>confdefs.h <<_ACEOF
 _ACEOF
 
 
-LVMCONFIG_PATH="$$BINDIR/lvmconfig"
+LVMCONFIG_PATH="$SBINDIR/lvmconfig"
 
 cat >>confdefs.h <<_ACEOF
 #define LVMCONFIG_PATH "$LVMCONFIG_PATH"
diff --git a/configure.ac b/configure.ac
index 8f5349f..6d9308f 100644
--- a/configure.ac
+++ b/configure.ac
@@ -1494,7 +1494,7 @@ SBINDIR="$(eval echo $(eval echo $sbindir))"
 LVM_PATH="$SBINDIR/lvm"
 AC_DEFINE_UNQUOTED(LVM_PATH, ["$LVM_PATH"], [Path to lvm binary.])
 
-LVMCONFIG_PATH="$$BINDIR/lvmconfig"
+LVMCONFIG_PATH="$SBINDIR/lvmconfig"
 AC_DEFINE_UNQUOTED(LVMCONFIG_PATH, ["$LVMCONFIG_PATH"], [Path to lvmconfig binary.])
 
 USRSBINDIR="$(eval echo $(eval echo $usrsbindir))"


