From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 13 Feb 2015 19:12:09 +0000 (UTC)
Subject: master - conf: Set default global/etc from --with-confdir.
Message-ID: <20150213191209.4550F608F3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=032c9178ca72aef93bfef6e4952bb98d3373b642
Commit:        032c9178ca72aef93bfef6e4952bb98d3373b642
Parent:        d726246f78ed7b8b957d45abe9084fb0b47c7240
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Fri Feb 13 19:10:10 2015 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Fri Feb 13 19:10:10 2015 +0000

conf: Set default global/etc from --with-confdir.

---
 conf/example.conf.in    |    3 +++
 configure               |    5 +++++
 configure.in            |    2 ++
 lib/config/defaults.h   |    1 -
 lib/misc/configure.h.in |    3 +++
 5 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/conf/example.conf.in b/conf/example.conf.in
index 5ee0c4d..777280e 100644
--- a/conf/example.conf.in
+++ b/conf/example.conf.in
@@ -565,6 +565,9 @@ global {
     # Defaults to "lvm2".
     # format = "lvm2"
 
+    # Location of /etc system configuration directory.
+    etc = "@CONFDIR@"
+
     # Location of proc filesystem
     proc = "/proc"
 
diff --git a/configure b/configure
index 3187473..ef0ae96 100755
--- a/configure
+++ b/configure
@@ -12260,6 +12260,11 @@ else
 fi
 
 
+cat >>confdefs.h <<_ACEOF
+#define DEFAULT_ETC_DIR "$CONFDIR"
+_ACEOF
+
+
 
 # Check whether --with-staticdir was given.
 if test "${with_staticdir+set}" = set; then :
diff --git a/configure.in b/configure.in
index b4b9ec2..73ca4cd 100644
--- a/configure.in
+++ b/configure.in
@@ -1452,6 +1452,8 @@ AC_ARG_WITH(confdir,
 	    AC_HELP_STRING([--with-confdir=DIR],
 			   [configuration files in DIR [/etc]]),
 	    CONFDIR=$withval, CONFDIR='/etc')
+AC_DEFINE_UNQUOTED(DEFAULT_ETC_DIR, ["$CONFDIR"],
+		   [Default system configuration directory.])
 
 AC_ARG_WITH(staticdir,
 	    AC_HELP_STRING([--with-staticdir=DIR],
diff --git a/lib/config/defaults.h b/lib/config/defaults.h
index 77604ab..9d2cff9 100644
--- a/lib/config/defaults.h
+++ b/lib/config/defaults.h
@@ -29,7 +29,6 @@
 
 #define DEFAULT_DEV_DIR "/dev"
 #define DEFAULT_PROC_DIR "/proc"
-#define DEFAULT_ETC_DIR "/etc"
 #define DEFAULT_OBTAIN_DEVICE_LIST_FROM_UDEV 1
 #define DEFAULT_EXTERNAL_DEVICE_INFO_SOURCE "none"
 #define DEFAULT_SYSFS_SCAN 1
diff --git a/lib/misc/configure.h.in b/lib/misc/configure.h.in
index 9a002d2..ee9f859 100644
--- a/lib/misc/configure.h.in
+++ b/lib/misc/configure.h.in
@@ -65,6 +65,9 @@
 /* Default DM run directory. */
 #undef DEFAULT_DM_RUN_DIR
 
+/* Default system configuration directory. */
+#undef DEFAULT_ETC_DIR
+
 /* Name of default locking directory. */
 #undef DEFAULT_LOCK_DIR
 


