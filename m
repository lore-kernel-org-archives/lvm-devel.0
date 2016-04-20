From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 20 Apr 2016 22:35:43 +0000 (UTC)
Subject: master - configure: detect for /var/lock dir
Message-ID: <20160420223543.6451B61EA6@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=600d7ca15f410c8abf41cee0195bc575148253b4
Commit:        600d7ca15f410c8abf41cee0195bc575148253b4
Parent:        5c104c5de9b019f5cf9b93ff2ee5468e1f0641d1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 20 23:15:00 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 20 23:32:51 2016 +0200

configure: detect for /var/lock dir

Detecs systems with /run/lock dir and use such path directly instead
of /var/lock.
---
 WHATS_NEW    |    1 +
 configure    |    9 +++++++--
 configure.in |    8 ++++++--
 3 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 4a435bb..10f688d 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.151 -
 =================================
+  Autodetect and use /run/lock dir when available instead of /var/lock.
   lvchange --refresh for merging thin origin will retry to deactivate snapshot.
   Recognize in-progress snapshot merge for thin volumes from dm table.
   Avoid deciding to initiate a pending snapshot merge during resume.
diff --git a/configure b/configure
index eb55243..c2de9a8 100755
--- a/configure
+++ b/configure
@@ -1820,7 +1820,7 @@ Optional Packages:
   --with-default-cache-subdir=SUBDIR
                           default metadata cache subdir [cache]
   --with-default-locking-dir=DIR
-                          default locking directory [/var/lock/lvm]
+                          default locking directory [autodetect_lock_dir/lvm]
   --with-default-data-alignment=NUM
                           set the default data alignment in MiB [1]
   --with-interface=IFACE  choose kernel interface (ioctl) [ioctl]
@@ -15113,7 +15113,12 @@ _ACEOF
 if test "${with_default_locking_dir+set}" = set; then :
   withval=$with_default_locking_dir; DEFAULT_LOCK_DIR=$withval
 else
-  DEFAULT_LOCK_DIR="/var/lock/lvm"
+  { $as_echo "$as_me:${as_lineno-$LINENO}: checking for default lock directory" >&5
+$as_echo_n "checking for default lock directory... " >&6; }
+	     DEFAULT_LOCK_DIR="$RUN_DIR/lock/lvm"
+	     test -d "$RUN_DIR/lock" || DEFAULT_LOCK_DIR="/var/lock/lvm"
+	     { $as_echo "$as_me:${as_lineno-$LINENO}: result: $DEFAULT_LOCK_DIR" >&5
+$as_echo "$DEFAULT_LOCK_DIR" >&6; }
 fi
 
 
diff --git a/configure.in b/configure.in
index 33cd0fe..4161df7 100644
--- a/configure.in
+++ b/configure.in
@@ -1933,8 +1933,12 @@ AC_DEFINE_UNQUOTED(DEFAULT_CACHE_SUBDIR, ["$DEFAULT_CACHE_SUBDIR"],
 
 AC_ARG_WITH(default-locking-dir,
 	    AC_HELP_STRING([--with-default-locking-dir=DIR],
-			   [default locking directory [/var/lock/lvm]]),
-	    DEFAULT_LOCK_DIR=$withval, DEFAULT_LOCK_DIR="/var/lock/lvm")
+			   [default locking directory [autodetect_lock_dir/lvm]]),
+	    DEFAULT_LOCK_DIR=$withval,
+	    [AC_MSG_CHECKING(for default lock directory)
+	     DEFAULT_LOCK_DIR="$RUN_DIR/lock/lvm"
+	     test -d "$RUN_DIR/lock" || DEFAULT_LOCK_DIR="/var/lock/lvm"
+	     AC_MSG_RESULT($DEFAULT_LOCK_DIR)])
 AC_DEFINE_UNQUOTED(DEFAULT_LOCK_DIR, ["$DEFAULT_LOCK_DIR"],
 		   [Name of default locking directory.])
 


