From: Heiko Becker <heirecka@exherbo.org>
Date: Thu, 13 Apr 2017 09:07:49 +0200
Subject: [PATCH] configure: Search for (a possibly prefixed) ar
Message-ID: <20170413070749.29364-1-heirecka@exherbo.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

e.g. when cross compiling.

Signed-off-by: Heiko Becker <heirecka@exherbo.org>
---
 configure.in | 1 +
 make.tmpl.in | 2 +-
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/configure.in b/configure.in
index 42ec52f95..d99a6e7b4 100644
--- a/configure.in
+++ b/configure.in
@@ -84,6 +84,7 @@ AC_PROG_LN_S
 AC_PROG_MAKE_SET
 AC_PROG_MKDIR_P
 AC_PROG_RANLIB
+AC_CHECK_TOOL(AR, ar)
 AC_PATH_TOOL(CFLOW_CMD, cflow)
 AC_PATH_TOOL(CSCOPE_CMD, cscope)
 AC_PATH_TOOL(CHMOD, chmod)
diff --git a/make.tmpl.in b/make.tmpl.in
index 8148fb551..5eeda2869 100644
--- a/make.tmpl.in
+++ b/make.tmpl.in
@@ -44,7 +44,7 @@ EGREP = @EGREP@
 GREP = @GREP@
 SORT = @SORT@
 WC = @WC@
-AR = ar
+AR = @AR@
 RM = rm -f
 
 PYTHON2 = @PYTHON2@
-- 
2.12.2


