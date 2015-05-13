From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 13 May 2015 11:20:42 +0000 (UTC)
Subject: master - configure: start to use AS_IF
Message-ID: <20150513112042.6631760067@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cc560b75aa5144ce6859e6d0ecc4cb918af7f4d8
Commit:        cc560b75aa5144ce6859e6d0ecc4cb918af7f4d8
Parent:        007ac0d36f2430a7a9048e2bc7f20cb5a204c413
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue May 12 14:46:36 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 13 13:19:36 2015 +0200

configure: start to use AS_IF

---
 configure    |   16 ++++++++++++----
 configure.in |   12 ++++++++----
 2 files changed, 20 insertions(+), 8 deletions(-)

diff --git a/configure b/configure
index 7c1ffe0..9babc59 100755
--- a/configure
+++ b/configure
@@ -14603,14 +14603,22 @@ $as_echo "$as_me: WARNING: unrecognized options: $ac_unrecognized_opts" >&2;}
 fi
 
 
-test -n "$THIN_CONFIGURE_WARN" && { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Support for thin provisioning is limited since some thin provisioning tools are missing!" >&5
+if test -n "$THIN_CONFIGURE_WARN"; then :
+  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Support for thin provisioning is limited since some thin provisioning tools are missing!" >&5
 $as_echo "$as_me: WARNING: Support for thin provisioning is limited since some thin provisioning tools are missing!" >&2;}
+fi
 
-test -n "$THIN_CHECK_VERSION_WARN" && { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: You should also install thin_check vsn 0.3.2 (or later) to use lvm2 thin provisioning" >&5
+if test -n "$THIN_CHECK_VERSION_WARN"; then :
+  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: You should also install thin_check vsn 0.3.2 (or later) to use lvm2 thin provisioning" >&5
 $as_echo "$as_me: WARNING: You should also install thin_check vsn 0.3.2 (or later) to use lvm2 thin provisioning" >&2;}
+fi
 
-test -n "$CACHE_CONFIGURE_WARN" && { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Support for cache is limited since some cache tools are missing!" >&5
+if test -n "$CACHE_CONFIGURE_WARN"; then :
+  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: Support for cache is limited since some cache tools are missing!" >&5
 $as_echo "$as_me: WARNING: Support for cache is limited since some cache tools are missing!" >&2;}
+fi
 
-test "$ODIRECT" = yes || { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: O_DIRECT disabled: low-memory pvmove may lock up" >&5
+if test "$ODIRECT" != yes; then :
+  { $as_echo "$as_me:${as_lineno-$LINENO}: WARNING: O_DIRECT disabled: low-memory pvmove may lock up" >&5
 $as_echo "$as_me: WARNING: O_DIRECT disabled: low-memory pvmove may lock up" >&2;}
+fi
diff --git a/configure.in b/configure.in
index 83358f5..c3222ed 100644
--- a/configure.in
+++ b/configure.in
@@ -1955,10 +1955,14 @@ unit-tests/mm/Makefile
 ])
 AC_OUTPUT
 
-test -n "$THIN_CONFIGURE_WARN" && AC_MSG_WARN([Support for thin provisioning is limited since some thin provisioning tools are missing!])
+AS_IF([test -n "$THIN_CONFIGURE_WARN"],
+      [AC_MSG_WARN([Support for thin provisioning is limited since some thin provisioning tools are missing!])])
 
-test -n "$THIN_CHECK_VERSION_WARN" && AC_MSG_WARN([You should also install thin_check vsn 0.3.2 (or later) to use lvm2 thin provisioning])
+AS_IF([test -n "$THIN_CHECK_VERSION_WARN"],
+      [AC_MSG_WARN([You should also install thin_check vsn 0.3.2 (or later) to use lvm2 thin provisioning])])
 
-test -n "$CACHE_CONFIGURE_WARN" && AC_MSG_WARN([Support for cache is limited since some cache tools are missing!])
+AS_IF([test -n "$CACHE_CONFIGURE_WARN"],
+      [AC_MSG_WARN([Support for cache is limited since some cache tools are missing!])])
 
-test "$ODIRECT" = yes || AC_MSG_WARN([O_DIRECT disabled: low-memory pvmove may lock up])
+AS_IF([test "$ODIRECT" != yes],
+      [AC_MSG_WARN([O_DIRECT disabled: low-memory pvmove may lock up])])


