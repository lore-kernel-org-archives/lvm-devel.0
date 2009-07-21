From: Thomas Woerner <twoerner@redhat.com>
Date: Tue, 21 Jul 2009 17:42:04 +0200
Subject: [PATCH] Add liblvm2app api version as so minor version number for liblvm2app.so.<major>.<lvm2app api version>
Message-ID: <1248190924-14854-1-git-send-email-twoerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Extend VERSION from "<major>.<minor>.<patchlevel>[-<tag>] (date)" to
"<major>.<minor>.<patchlevel>(<lvm2app api version>)[-<tag>] (date)".
Change parsing of LVM_RELEASE_DATE that it expects a ' ' before the date.
Change parsing of LVM_RELEASE and LVM_PATCHLEVEL that it honors '(' before after the patchlevel.
Add LIB_VERSION_APPLIB to get <major>.<lvm2app api version> from VERSION.
---
 VERSION      |    2 +-
 configure    |    6 +++---
 configure.in |    6 +++---
 make.tmpl.in |    3 +++
 4 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/VERSION b/VERSION
index c901e1d..728793b 100644
--- a/VERSION
+++ b/VERSION
@@ -1 +1 @@
-2.02.50-cvs (2009-07-15)
+2.02.50(01)-cvs (2009-07-15)
diff --git a/configure b/configure
index 2b8d9d7..5c9bdfc 100755
--- a/configure
+++ b/configure
@@ -12606,13 +12606,13 @@ DM_LIB_PATCHLEVEL=`cat VERSION_DM | $AWK -F '[-. ]' '{printf "%s.%s.%s",$1,$2,$3
 LVM_VERSION="\"`cat VERSION 2>/dev/null || echo Unknown`\""
 
 VER=`cat VERSION`
-LVM_RELEASE_DATE="\"`echo $VER | $SED 's/.*(//;s/).*//'`\""
+LVM_RELEASE_DATE="\"`echo $VER | $SED 's/.* (//;s/).*//'`\""
 VER=`echo "$VER" | $AWK '{print $1}'`
-LVM_RELEASE="\"`echo "$VER" | $AWK -F '-' '{print $2}'`\""
+LVM_RELEASE="\"`echo "$VER" | $AWK -F '[(-]' '{print $2}'`\""
 VER=`echo "$VER" | $AWK -F '-' '{print $1}'`
 LVM_MAJOR=`echo "$VER" | $AWK -F '.' '{print $1}'`
 LVM_MINOR=`echo "$VER" | $AWK -F '.' '{print $2}'`
-LVM_PATCHLEVEL=`echo "$VER" | $AWK -F '.' '{print $3}'`
+LVM_PATCHLEVEL=`echo "$VER" | $AWK -F '[(.]' '{print $3}'`
 
 ################################################################################
 
diff --git a/configure.in b/configure.in
index eb6278d..d0e68a6 100644
--- a/configure.in
+++ b/configure.in
@@ -750,13 +750,13 @@ DM_LIB_PATCHLEVEL=`cat VERSION_DM | $AWK -F '[[-. ]]' '{printf "%s.%s.%s",$1,$2,
 LVM_VERSION="\"`cat VERSION 2>/dev/null || echo Unknown`\""
 
 VER=`cat VERSION`
-LVM_RELEASE_DATE="\"`echo $VER | $SED 's/.*(//;s/).*//'`\""
+LVM_RELEASE_DATE="\"`echo $VER | $SED 's/.* (//;s/).*//'`\""
 VER=`echo "$VER" | $AWK '{print $1}'`
-LVM_RELEASE="\"`echo "$VER" | $AWK -F '-' '{print $2}'`\""
+LVM_RELEASE="\"`echo "$VER" | $AWK -F '[[(-]]' '{print $2}'`\""
 VER=`echo "$VER" | $AWK -F '-' '{print $1}'`
 LVM_MAJOR=`echo "$VER" | $AWK -F '.' '{print $1}'`
 LVM_MINOR=`echo "$VER" | $AWK -F '.' '{print $2}'`
-LVM_PATCHLEVEL=`echo "$VER" | $AWK -F '.' '{print $3}'`
+LVM_PATCHLEVEL=`echo "$VER" | $AWK -F '[[(.]]' '{print $3}'`
 
 ################################################################################
 AC_SUBST(APPLIB)
diff --git a/make.tmpl.in b/make.tmpl.in
index fa3b884..5556d16 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -116,6 +116,9 @@ LIB_VERSION_LVM := $(shell cat $(top_srcdir)/VERSION | \
 LIB_VERSION_DM := $(shell cat $(top_srcdir)/VERSION_DM | \
 		    awk -F '.' '{printf "%s.%s",$$1,$$2}')
 
+LIB_VERSION_APPLIB := $(shell cat $(top_srcdir)/VERSION | \
+		   awk -F '[(). ]' '{printf "%s.%s",$$1,$$4}')
+
 INCLUDES += -I. -I$(top_srcdir)/include
 
 INC_LNS = $(top_srcdir)/include/.symlinks_created
-- 
1.6.2.5


