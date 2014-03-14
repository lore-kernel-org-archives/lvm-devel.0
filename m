From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 14 Mar 2014 10:17:40 +0000 (UTC)
Subject: master - tests: use DMEVENTD_PIDFILE
Message-ID: <20140314101740.C177760217@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=58e812a13ff725d9ca8958fe04b92fef320bce31
Commit:        58e812a13ff725d9ca8958fe04b92fef320bce31
Parent:        ca880a4f130a0d6111613e23f926c344217581a2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 14 11:12:46 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Mar 14 11:16:24 2014 +0100

tests: use DMEVENTD_PIDFILE

Test for compiled-in pidfile location
(so we are not based on assumption /var/run or /run link exists)
---
 test/Makefile.in |    1 +
 test/lib/aux.sh  |    6 +++++-
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index bf1913a..9335abd 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -136,6 +136,7 @@ lib/paths: $(srcdir)/Makefile.in .lib-dir-stamp
 	echo 'export DM_UDEV_SYNCHRONISATION=$(dm_udev_synchronisation)' >> $@-t
 	echo 'export THIN=@THIN@' >> $@-t
 	echo 'export LVMETAD_PIDFILE=@LVMETAD_PIDFILE@' >> $@-t
+	echo 'export DMEVENTD_PIDFILE=@DMEVENTD_PIDFILE@' >> $@-t
 	mv $@-t $@
 
 LIB = lib/not lib/should lib/harness \
diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 7d13e8d..bd292bb 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -68,7 +68,11 @@ prepare_dmeventd() {
 	echo $! > LOCAL_DMEVENTD
 
 	# FIXME wait for pipe in /var/run instead
-	while ! test -e "/run/dmeventd.pid"; do echo -n .; sleep .2; done # wait for the socket
+	for i in $(seq 1 100) ; do
+		test $i -eq 100 && die "Startup of dmeventd is too slow."
+		test -e "${DMEVENTD_PIDFILE}" && break
+		sleep .2
+	done
 	echo ok
 }
 


