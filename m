From: Thomas Woerner <twoerner@redhat.com>
Date: Wed, 22 Jul 2009 17:38:13 +0200
Subject: [PATCH 2/5] Use LIB_VERSION_APPLIB as liblvm so version.
In-Reply-To: <1248277096-29947-2-git-send-email-twoerner@redhat.com>
References: <1248277096-29947-1-git-send-email-twoerner@redhat.com>
	<1248277096-29947-2-git-send-email-twoerner@redhat.com>
Message-ID: <1248277096-29947-3-git-send-email-twoerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Thomas Woerner <twoerner@redhat.com>
---
 liblvm/Makefile.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/liblvm/Makefile.in b/liblvm/Makefile.in
index 643cc0c..a330f1e 100644
--- a/liblvm/Makefile.in
+++ b/liblvm/Makefile.in
@@ -22,7 +22,7 @@ SOURCES =\
 
 LIB_NAME = liblvm2app
 LIB_VERSION = $(LIB_VERSION_LVM)
-VERSIONED_SHLIB = $(LIB_NAME).$(LIB_SUFFIX).$(LIB_VERSION_LVM)
+VERSIONED_SHLIB = $(LIB_NAME).$(LIB_SUFFIX).$(LIB_VERSION_APPLIB)
 
 ifeq ("@STATIC_LINK@", "yes")
 LIB_STATIC = $(LIB_NAME).a
@@ -35,7 +35,7 @@ include $(top_srcdir)/make.tmpl
 
 LIBS += -ldevmapper -llvm-internal
 
-$(VERSIONED_SHLIB): %.$(LIB_SUFFIX).$(LIB_VERSION): %.$(LIB_SUFFIX)
+$(VERSIONED_SHLIB): %.$(LIB_SUFFIX).$(LIB_VERSION_APPLIB): %.$(LIB_SUFFIX)
 	rm -f $@
 	$(LN_S) $< $@
 
-- 
1.6.2.5


