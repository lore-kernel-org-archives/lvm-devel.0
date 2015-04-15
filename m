From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 15 Apr 2015 11:38:13 +0000 (UTC)
Subject: master - makefiles: fix usage of default value
Message-ID: <20150415113813.4A98860612@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1a814af46b6c8163c6b9b60932f9d700583914b0
Commit:        1a814af46b6c8163c6b9b60932f9d700583914b0
Parent:        22defdac64703945938483433a8d7cc7e3708ef9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Apr 15 13:08:41 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Apr 15 13:35:42 2015 +0200

makefiles: fix usage of default value

When a var like LVM_TEST_THIN_CHECK_CMD is set to ""
(which is valid) we need to correctly use '-'.
Otherwise ':-' replaces such value with built-in default.
---
 test/Makefile.in |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/test/Makefile.in b/test/Makefile.in
index da09a6c..c99f8f2 100644
--- a/test/Makefile.in
+++ b/test/Makefile.in
@@ -188,14 +188,14 @@ lib/paths-common: $(srcdir)/Makefile.in .lib-dir-stamp Makefile
 	echo 'export LVMETAD_PIDFILE="@LVMETAD_PIDFILE@"' >> $@-t
 	echo 'export DMEVENTD_PIDFILE="@DMEVENTD_PIDFILE@"' >> $@-t
 	echo 'export CLVMD_PIDFILE="@CLVMD_PIDFILE@"' >> $@-t
-	echo 'export LVM_TEST_THIN_CHECK_CMD=$${LVM_TEST_THIN_CHECK_CMD:- at THIN_CHECK_CMD@}' >> $@-t
-	echo 'export LVM_TEST_THIN_DUMP_CMD=$${LVM_TEST_THIN_DUMP_CMD:- at THIN_DUMP_CMD@}' >> $@-t
-	echo 'export LVM_TEST_THIN_REPAIR_CMD=$${LVM_TEST_THIN_REPAIR_CMD:- at THIN_REPAIR_CMD@}' >> $@-t
-	echo 'export LVM_TEST_THIN_RESTORE_CMD=$${LVM_TEST_THIN_RESTORE_CMD:- at THIN_RESTORE_CMD@}' >> $@-t
-	echo 'export LVM_TEST_CACHE_CHECK_CMD=$${LVM_TEST_CACHE_CHECK_CMD:- at CACHE_CHECK_CMD@}' >> $@-t
-	echo 'export LVM_TEST_CACHE_DUMP_CMD=$${LVM_TEST_CACHE_DUMP_CMD:- at CACHE_DUMP_CMD@}' >> $@-t
-	echo 'export LVM_TEST_CACHE_REPAIR_CMD=$${LVM_TEST_CACHE_REPAIR_CMD:- at CACHE_REPAIR_CMD@}' >> $@-t
-	echo 'export LVM_TEST_CACHE_RESTORE_CMD=$${LVM_TEST_CACHE_RESTORE_CMD:- at CACHE_RESTORE_CMD@}' >> $@-t
+	echo 'export LVM_TEST_THIN_CHECK_CMD=$${LVM_TEST_THIN_CHECK_CMD- at THIN_CHECK_CMD@}' >> $@-t
+	echo 'export LVM_TEST_THIN_DUMP_CMD=$${LVM_TEST_THIN_DUMP_CMD- at THIN_DUMP_CMD@}' >> $@-t
+	echo 'export LVM_TEST_THIN_REPAIR_CMD=$${LVM_TEST_THIN_REPAIR_CMD- at THIN_REPAIR_CMD@}' >> $@-t
+	echo 'export LVM_TEST_THIN_RESTORE_CMD=$${LVM_TEST_THIN_RESTORE_CMD- at THIN_RESTORE_CMD@}' >> $@-t
+	echo 'export LVM_TEST_CACHE_CHECK_CMD=$${LVM_TEST_CACHE_CHECK_CMD- at CACHE_CHECK_CMD@}' >> $@-t
+	echo 'export LVM_TEST_CACHE_DUMP_CMD=$${LVM_TEST_CACHE_DUMP_CMD- at CACHE_DUMP_CMD@}' >> $@-t
+	echo 'export LVM_TEST_CACHE_REPAIR_CMD=$${LVM_TEST_CACHE_REPAIR_CMD- at CACHE_REPAIR_CMD@}' >> $@-t
+	echo 'export LVM_TEST_CACHE_RESTORE_CMD=$${LVM_TEST_CACHE_RESTORE_CMD- at CACHE_RESTORE_CMD@}' >> $@-t
 	mv $@-t $@
 
 lib/paths-installed: lib/paths-common


