From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 24 Oct 2013 16:11:16 +0000 (UTC)
Subject: master - build: Use additional gcc warning flags.
Message-ID: <20131024161116.4F8C96106D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c9c23d414802ed07c7638ce13d33dba3a629e887
Commit:        c9c23d414802ed07c7638ce13d33dba3a629e887
Parent:        d5896f0afd28096c3dc04a9c7e9627b387f145fb
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Oct 24 17:10:24 2013 +0100
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Oct 24 17:10:24 2013 +0100

build: Use additional gcc warning flags.

---
 WHATS_NEW    |    3 ++-
 make.tmpl.in |   12 +++++++++---
 2 files changed, 11 insertions(+), 4 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 7106867..cb3488b 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
-Version 2.02.104
+Version 2.02.104 -
 ===================================
+  Use additional gcc warning flags by default.
   Add ignore_lvm_mirrors to config file to read/ignore labels on mirrors.
   Add internal flag for temporary LVs to properly direct udev to not interfere.
   Fix endless loop in blkdeactivate <device>... if unable to umount/deactivate.
diff --git a/make.tmpl.in b/make.tmpl.in
index 3218758..788eb1d 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -135,9 +135,15 @@ INSTALL_SCRIPT = $(INSTALL) -p $(M_INSTALL_PROGRAM)
 WFLAGS += -Wall -Wundef -Wshadow -Wcast-align -Wwrite-strings \
  -Wmissing-prototypes -Wmissing-declarations -Wnested-externs \
  -Winline -Wmissing-noreturn -Wformat-security -Wredundant-decls \
- -Wpointer-arith
-
-#WFLAGS += -W -Wconversion -Wbad-function-cast -Wcast-qual
+ -Wpointer-arith -Wclobbered -Wempty-body -Wignored-qualifiers \
+ -Wmissing-parameter-type -Wold-style-declaration -Woverride-init \
+ -Wtype-limits -Wuninitialized -Wmissing-include-dirs -Wsync-nand \
+ -Wfloat-equal -Wjump-misses-init -Wlogical-op -Wstrict-prototypes \
+ -Wold-style-definition -Wmissing-format-attribute
+
+#WFLAGS += -W -Wno-sign-compare -Wno-unused-parameter -Wno-missing-field-initializers
+#WFLAGS += -Wsign-compare -Wunused-parameter -Wmissing-field-initializers 
+#WFLAGS += -Wconversion -Wbad-function-cast -Wcast-qual -Waggregate-return -Wpacked
 #WFLAGS += -pedantic -std=gnu99
 #DEFS += -DDEBUG_CRC32
 


