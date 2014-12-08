From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon,  8 Dec 2014 09:56:30 +0000 (UTC)
Subject: master - configure: fix automatic use of configure --enable-udev-systemd-background-jobs
Message-ID: <20141208095630.00AF060F70@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4c62215bd178c17d0776448bdc99740180c85402
Commit:        4c62215bd178c17d0776448bdc99740180c85402
Parent:        42d71b9af393bdbf0e9409eea176b2801a07ea25
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Dec 8 10:51:33 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Dec 8 10:52:47 2014 +0100

configure: fix automatic use of configure --enable-udev-systemd-background-jobs

Fix incorrect test in configure which sets --enable-udev-systemd-background-jobs
automatically if proper systemd version is available.

The UDEV_SYSTEMD_BACKGROUND_JOBS variable was not properly set to "yes" in
case systemd is available and we had "maybe" for this variable before.
---
 WHATS_NEW    |    1 +
 configure    |    2 +-
 configure.in |    2 +-
 3 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 213cc31..9201f36 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.115 -
 =====================================
+  Fix automatic use of configure --enable-udev-systemd-background-jobs.
   Correctly rename active split LV with -splitmirrors for raid1.
   Add report/compact_output to lvm.conf to enable/disable compact report output.
   Still restrict mirror region size to power of 2 when VG extent size is not.
diff --git a/configure b/configure
index df902c3..9d1d32f 100755
--- a/configure
+++ b/configure
@@ -10694,7 +10694,7 @@ else
 	SYSTEMD_LIBS=$pkg_cv_SYSTEMD_LIBS
         { $as_echo "$as_me:${as_lineno-$LINENO}: result: yes" >&5
 $as_echo "yes" >&6; }
-	test "UDEV_SYSTEMD_BACKGROUND_JOBS" = maybe && UDEV_SYSTEMD_BACKGROUND_JOBS=yes
+	test "$UDEV_SYSTEMD_BACKGROUND_JOBS" = maybe && UDEV_SYSTEMD_BACKGROUND_JOBS=yes
 fi
 fi
 
diff --git a/configure.in b/configure.in
index 5b22b93..107bb29 100644
--- a/configure.in
+++ b/configure.in
@@ -1104,7 +1104,7 @@ AC_MSG_RESULT($UDEV_SYSTEMD_BACKGROUND_JOBS)
 if test "$UDEV_SYSTEMD_BACKGROUND_JOBS" != no; then
 	pkg_config_init
 	PKG_CHECK_MODULES(SYSTEMD, systemd >= 205,
-			  [test "UDEV_SYSTEMD_BACKGROUND_JOBS" = maybe && UDEV_SYSTEMD_BACKGROUND_JOBS=yes],
+			  [test "$UDEV_SYSTEMD_BACKGROUND_JOBS" = maybe && UDEV_SYSTEMD_BACKGROUND_JOBS=yes],
 			  [if test "$UDEV_SYSTEMD_BACKGROUND_JOBS" = maybe; then
 				UDEV_SYSTEMD_BACKGROUND_JOBS=no
 			   else


