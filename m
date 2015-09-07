From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  7 Sep 2015 15:45:19 +0000 (UTC)
Subject: master - configure: simpler version reading
Message-ID: <20150907154519.CA71860F6B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1999e368f16cf7537c553be573809713213fdacd
Commit:        1999e368f16cf7537c553be573809713213fdacd
Parent:        fc4f0d3fce05a601e768dbfb315b0c7e6d6c0030
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 7 13:58:54 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 7 17:43:27 2015 +0200

configure: simpler version reading

Avoid calling 'cat' when 'read' could handle it.

Also drop DM_LIB_VERSION from AC_SUBST as it's not used anywhere
in .in file.
---
 configure.in |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/configure.in b/configure.in
index 4843678..31f4b3a 100644
--- a/configure.in
+++ b/configure.in
@@ -1888,14 +1888,14 @@ test "$interface" != ioctl && AC_MSG_ERROR([--with-interface=ioctl required. fs
 AC_MSG_RESULT($interface)
 
 ################################################################################
-DM_LIB_VERSION="\"`cat "$srcdir"/VERSION_DM 2>/dev/null || echo Unknown`\""
-AC_DEFINE_UNQUOTED(DM_LIB_VERSION, $DM_LIB_VERSION, [Library version])
+read DM_LIB_VERSION < "$srcdir"/VERSION_DM 2>/dev/null || DM_LIB_VERSION=Unknown
+AC_DEFINE_UNQUOTED(DM_LIB_VERSION, "$DM_LIB_VERSION", [Library version])
 
 DM_LIB_PATCHLEVEL=`cat "$srcdir"/VERSION_DM | $AWK -F '[[-. ]]' '{printf "%s.%s.%s",$1,$2,$3}'`
 
-LVM_VERSION="\"`cat "$srcdir"/VERSION 2>/dev/null || echo Unknown`\""
+read VER < "$srcdir"/VERSION 2>/dev/null || VER=Unknown
 
-VER=`cat "$srcdir"/VERSION`
+LVM_VERSION=\"$VER\"
 LVM_RELEASE_DATE="\"`echo $VER | $SED 's/.* (//;s/).*//'`\""
 VER=`echo "$VER" | $AWK '{print $1}'`
 LVM_RELEASE="\"`echo "$VER" | $AWK -F '-' '{print $2}'`\""
@@ -1963,7 +1963,6 @@ AC_SUBST(DLM_LIBS)
 AC_SUBST(DL_LIBS)
 AC_SUBST(DMEVENTD)
 AC_SUBST(DMEVENTD_PATH)
-AC_SUBST(DM_LIB_VERSION)
 AC_SUBST(DM_LIB_PATCHLEVEL)
 AC_SUBST(ELDFLAGS)
 AC_SUBST(FSADM)


