From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 9 Jun 2017 16:56:44 -0400
Subject: master - configure: search for (a possibly prefixed) ar
Message-ID: <201706092056.v59Kui21018658@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4b4a210e8397a37446fe7229242868055af9cd81
Commit:        4b4a210e8397a37446fe7229242868055af9cd81
Parent:        5ef20d2168176f598d13e0b7bcc658b976813d5c
Author:        Heiko Becker <heirecka@exherbo.org>
AuthorDate:    Thu Apr 13 09:07:49 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Jun 9 22:49:39 2017 +0200

configure: search for (a possibly prefixed) ar

e.g. when cross compiling.

Signed-off-by: Heiko Becker <heirecka@exherbo.org>
---
 configure.in |    1 +
 make.tmpl.in |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/configure.in b/configure.in
index ae5baa5..2e5e015 100644
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
index a40eaaa..cb5953a 100644
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


