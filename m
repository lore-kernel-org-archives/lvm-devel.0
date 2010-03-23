From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 23 Mar 2010 17:27:37 +0100
Subject: [PATCH 4/6] Fix run of cscope in $(builddir)
In-Reply-To: <cover.1269361453.git.zkabelac@redhat.com>
References: <cover.1269361453.git.zkabelac@redhat.com>
Message-ID: <1c66e7b266b2d642424fafaca68669d1d8a15c49.1269361453.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use $(top_srcdir) for sources and add cscope.out to distcleaning.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 Makefile.in |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/Makefile.in b/Makefile.in
index 593500e..967b026 100644
--- a/Makefile.in
+++ b/Makefile.in
@@ -81,8 +81,9 @@ endif
 
 ifneq ("@CSCOPE_CMD@", "")
 cscope.out: tools
-	@CSCOPE_CMD@ -b -R
+	@CSCOPE_CMD@ -b -R $(top_srcdir)
 all: cscope.out
+DISTCLEAN_TARGETS += cscope.out
 endif
 
 check: all
-- 
1.7.0.1


