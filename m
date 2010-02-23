From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 23 Feb 2010 14:30:26 -0500
Subject: [PATCH 4/4] Add lvm_list_all.c to lvm2app nightly tests.
In-Reply-To: <1266953426-20955-4-git-send-email-dwysocha@redhat.com>
References: <1266427744-30327-9-git-send-email-dwysocha@redhat.com>
	<1266953426-20955-1-git-send-email-dwysocha@redhat.com>
	<1266953426-20955-2-git-send-email-dwysocha@redhat.com>
	<1266953426-20955-3-git-send-email-dwysocha@redhat.com>
	<1266953426-20955-4-git-send-email-dwysocha@redhat.com>
Message-ID: <1266953426-20955-5-git-send-email-dwysocha@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This code also shows up as an example in the documentation.
To ensure it continues to compile and work, we build it as part of the
nightly lvm2app tests.

Signed-off-by: Dave Wysochanski <dwysocha@redhat.com>
---
 test/api/Makefile.in |    7 ++++++-
 test/lvm2app.sh      |    7 ++++++-
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/test/api/Makefile.in b/test/api/Makefile.in
index 2c0c62f..2c554f8 100644
--- a/test/api/Makefile.in
+++ b/test/api/Makefile.in
@@ -20,9 +20,10 @@ ifeq ("@DEBUG@", "yes")
 	DEFS += -DDEBUG
 endif
 
-TARGETS = vgtest
+TARGETS = vgtest lvm_list_all
 test_SOURCES = test.c
 vgtest_SOURCES = vgtest.c
+lvm_list_all_SOURCES = lvm_list_all.c
 INCLUDES += -I../../include
 
 LVMLIBS = @LVM2APP_LIB@ -ldevmapper
@@ -41,6 +42,7 @@ endif
 
 test_OBJECTS = $(test_SOURCES:.c=.o)
 vgtest_OBJECTS = $(vgtest_SOURCES:.c=.o)
+lvm_list_all_OBJECTS = $(lvm_list_all_SOURCES:.c=.o)
 OBJECTS = $(test_OBJECTS) $(vgtest_OBJECTS)
 
 test: $(test_OBJECTS) $(DEPLIBS)
@@ -48,3 +50,6 @@ test: $(test_OBJECTS) $(DEPLIBS)
 
 vgtest: $(vgtest_OBJECTS) $(DEPLIBS)
 	$(CC) -o vgtest $(vgtest_OBJECTS) $(CFLAGS) $(LDFLAGS) $(LVMLIBS) $(LIBS)
+
+lvm_list_all: $(lvm_list_all_OBJECTS) $(DEPLIBS)
+	$(CC) -o lvm_list_all $(lvm_list_all_OBJECTS) $(CFLAGS) $(LDFLAGS) $(LVMLIBS) $(LIBS)
diff --git a/test/lvm2app.sh b/test/lvm2app.sh
index f253b46..3d911ab 100755
--- a/test/lvm2app.sh
+++ b/test/lvm2app.sh
@@ -14,10 +14,15 @@
 
 . ./test-utils.sh
 
-aux prepare_devs 2
+aux prepare_devs 5
 
 pvcreate $dev1 $dev2
 
 echo `pwd`
 ls -lR `pwd`
 $abs_srcdir/api/vgtest $vg1 $dev1 $dev2
+vgcreate $vg1 $dev1 $dev2
+vgcreate $vg2 $dev3 $dev4
+lvcreate -l 4 -n $lv1 $vg1
+lvcreate -l 4 -n $lv2 $vg2
+$abs_srcdir/api/lvm_list_all
-- 
1.6.0.6


