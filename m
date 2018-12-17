From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Dec 2018 05:08:31 -0500
Subject: master - makefiles: sort
Message-ID: <201812171008.wBHA8VLs024801@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d76b4afb8ed9531c1609804b684900a0ea96815c
Commit:        d76b4afb8ed9531c1609804b684900a0ea96815c
Parent:        a8cdd9e16a04ca837401cbcaa4677b2af50007b7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 14 21:50:09 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 17 10:36:52 2018 +0100

makefiles: sort

---
 base/Makefile                |    4 ++--
 daemons/lvmdbusd/Makefile.in |    6 +++---
 device_mapper/Makefile       |    6 +++---
 test/unit/Makefile           |    4 ++--
 tools/Makefile.in            |    4 ++--
 5 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/base/Makefile b/base/Makefile
index f150ad9..6050c3a 100644
--- a/base/Makefile
+++ b/base/Makefile
@@ -18,9 +18,9 @@
 #       which defined all top_* variables
 
 BASE_SOURCE=\
-	base/data-struct/radix-tree.c \
 	base/data-struct/hash.c \
-	base/data-struct/list.c
+	base/data-struct/list.c \
+	base/data-struct/radix-tree.c
 
 BASE_DEPENDS = $(BASE_SOURCE:%.c=%.d)
 BASE_OBJECTS = $(BASE_SOURCE:%.c=%.o)
diff --git a/daemons/lvmdbusd/Makefile.in b/daemons/lvmdbusd/Makefile.in
index 8d5de28..da96c34 100644
--- a/daemons/lvmdbusd/Makefile.in
+++ b/daemons/lvmdbusd/Makefile.in
@@ -23,11 +23,10 @@ LVMDBUS_SRCDIR_FILES = \
 	cfg.py \
 	cmdhandler.py \
 	fetch.py \
-	__init__.py \
 	job.py \
 	loader.py \
-	main.py \
 	lv.py \
+	main.py \
 	manager.py \
 	objectmanager.py \
 	pv.py \
@@ -35,7 +34,8 @@ LVMDBUS_SRCDIR_FILES = \
 	state.py \
 	udevwatch.py \
 	utils.py \
-	vg.py
+	vg.py \
+	__init__.py
 
 LVMDBUS_BUILDDIR_FILES = \
 	lvmdb.py \
diff --git a/device_mapper/Makefile b/device_mapper/Makefile
index bb0880d..fd2189a 100644
--- a/device_mapper/Makefile
+++ b/device_mapper/Makefile
@@ -15,6 +15,7 @@
 
 DEVICE_MAPPER_SOURCE=\
 	device_mapper/datastruct/bitset.c \
+	device_mapper/ioctl/libdm-iface.c \
 	device_mapper/libdm-common.c \
 	device_mapper/libdm-config.c \
 	device_mapper/libdm-deptree.c \
@@ -27,9 +28,8 @@ DEVICE_MAPPER_SOURCE=\
 	device_mapper/regex/matcher.c \
 	device_mapper/regex/parse_rx.c \
 	device_mapper/regex/ttree.c \
-	device_mapper/ioctl/libdm-iface.c \
-	device_mapper/vdo/vdo_target.c \
-	device_mapper/vdo/status.c
+	device_mapper/vdo/status.c \
+	device_mapper/vdo/vdo_target.c
 
 DEVICE_MAPPER_DEPENDS = $(DEVICE_MAPPER_SOURCE:%.c=%.d)
 DEVICE_MAPPER_OBJECTS = $(DEVICE_MAPPER_SOURCE:%.c=%.o)
diff --git a/test/unit/Makefile b/test/unit/Makefile
index fa6acb6..5b71e1b 100644
--- a/test/unit/Makefile
+++ b/test/unit/Makefile
@@ -20,11 +20,11 @@ UNIT_SOURCE=\
 	test/unit/config_t.c \
 	test/unit/dmlist_t.c \
 	test/unit/dmstatus_t.c \
+	test/unit/framework.c \
 	test/unit/io_engine_t.c \
-	test/unit/radix_tree_t.c \
 	test/unit/matcher_t.c \
-	test/unit/framework.c \
 	test/unit/percent_t.c \
+	test/unit/radix_tree_t.c \
 	test/unit/run.c \
 	test/unit/string_t.c \
 	test/unit/vdo_t.c
diff --git a/tools/Makefile.in b/tools/Makefile.in
index 7b29517..09768ed 100644
--- a/tools/Makefile.in
+++ b/tools/Makefile.in
@@ -28,6 +28,7 @@ SOURCES =\
 	lvextend.c \
 	lvmcmdline.c \
 	lvmdiskscan.c \
+	lvpoll.c \
 	lvreduce.c \
 	lvremove.c \
 	lvrename.c \
@@ -56,10 +57,9 @@ SOURCES =\
 	vgexport.c \
 	vgextend.c \
 	vgimport.c \
+	vgimportclone.c \
 	vgmerge.c \
 	vgmknodes.c \
-	lvpoll.c \
-	vgimportclone.c \
 	vgreduce.c \
 	vgremove.c \
 	vgrename.c \


