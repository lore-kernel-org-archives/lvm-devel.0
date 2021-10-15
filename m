From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 15 Oct 2021 21:42:19 +0000 (GMT)
Subject: main - configure: fix use of withval
Message-ID: <20211015214219.6D0943858401@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8aefd97252ab5cde9811d93138239f3defeee73b
Commit:        8aefd97252ab5cde9811d93138239f3defeee73b
Parent:        bf87b8354d07dbddc520e8b61543128e2b2f1924
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 15 23:33:59 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 15 23:35:05 2021 +0200

configure: fix use of withval

Newly added option --with-default-use-devices-file needs to use withval.
---
 configure    | 3 +--
 configure.ac | 2 +-
 2 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/configure b/configure
index 642cb4f6b..5719be836 100755
--- a/configure
+++ b/configure
@@ -8467,11 +8467,10 @@ $as_echo_n "checking default for use_devicesfile... " >&6; }
 
 # Check whether --with-default-use-devices-file was given.
 if test "${with_default_use_devices_file+set}" = set; then :
-  withval=$with_default_use_devices_file; DEFAULT_USE_DEVICES_FILE=$enableval
+  withval=$with_default_use_devices_file; DEFAULT_USE_DEVICES_FILE=$withval
 else
   DEFAULT_USE_DEVICES_FILE=0
 fi
-
 case "$DEFAULT_USE_DEVICES_FILE" in
  0|1);;
  *) as_fn_error $? "--with-default-use-devices-file parameter invalid" "$LINENO" 5;;
diff --git a/configure.ac b/configure.ac
index 0069e5d36..2f821edae 100644
--- a/configure.ac
+++ b/configure.ac
@@ -290,7 +290,7 @@ dnl -- Default settings for lvm.conf { devices/use_devicesfile }
 AC_MSG_CHECKING(default for use_devicesfile)
 AC_ARG_WITH(default-use-devices-file,
 	      AS_HELP_STRING([--with-default-use-devices-file], [default for lvm.conf devices/use_devicesfile = [0]]),
-	      DEFAULT_USE_DEVICES_FILE=$enableval, DEFAULT_USE_DEVICES_FILE=0)
+	      DEFAULT_USE_DEVICES_FILE=$withval, DEFAULT_USE_DEVICES_FILE=0)
 case "$DEFAULT_USE_DEVICES_FILE" in
  0|1);;
  *) AC_MSG_ERROR([--with-default-use-devices-file parameter invalid]);;


