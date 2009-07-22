From: Thomas Woerner <twoerner@redhat.com>
Date: Wed, 22 Jul 2009 17:38:14 +0200
Subject: [PATCH 3/5] Remove LIB_STATIC remains from liblvm/Makefile.in.
In-Reply-To: <1248277096-29947-3-git-send-email-twoerner@redhat.com>
References: <1248277096-29947-1-git-send-email-twoerner@redhat.com>
	<1248277096-29947-2-git-send-email-twoerner@redhat.com>
	<1248277096-29947-3-git-send-email-twoerner@redhat.com>
Message-ID: <1248277096-29947-4-git-send-email-twoerner@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Thomas Woerner <twoerner@redhat.com>
---
 liblvm/Makefile.in |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/liblvm/Makefile.in b/liblvm/Makefile.in
index a330f1e..0deaeac 100644
--- a/liblvm/Makefile.in
+++ b/liblvm/Makefile.in
@@ -24,9 +24,6 @@ LIB_NAME = liblvm2app
 LIB_VERSION = $(LIB_VERSION_LVM)
 VERSIONED_SHLIB = $(LIB_NAME).$(LIB_SUFFIX).$(LIB_VERSION_APPLIB)
 
-ifeq ("@STATIC_LINK@", "yes")
-LIB_STATIC = $(LIB_NAME).a
-endif
 LIB_SHARED = $(LIB_NAME).so
 
 CLEAN_TARGETS += liblvm.cflow
-- 
1.6.2.5


