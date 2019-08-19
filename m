From: Marian Csontos <mcsontos@sourceware.org>
Date: Mon, 19 Aug 2019 09:33:44 -0400
Subject: master - configure: Fix the default in help string
Message-ID: <201908191333.x7JDXiZc010883@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=9b63f590168b14d0e996f62519edb27f24ab83e2
Commit:        9b63f590168b14d0e996f62519edb27f24ab83e2
Parent:        0534cd9cd4066c88a7dd815f2f3206a177169334
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Jul 31 16:24:18 2019 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Aug 19 15:28:01 2019 +0200

configure: Fix the default in help string

---
 configure.ac |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/configure.ac b/configure.ac
index 1e45c0e..5da6946 100644
--- a/configure.ac
+++ b/configure.ac
@@ -653,7 +653,7 @@ dnl -- writecache inclusion type
 AC_MSG_CHECKING(whether to include writecache)
 AC_ARG_WITH(writecache,
 	    AC_HELP_STRING([--with-writecache=TYPE],
-			   [writecache support: internal/none [internal]]),
+			   [writecache support: internal/none [none]]),
 			   WRITECACHE=$withval, WRITECACHE="none")
 
 AC_MSG_RESULT($WRITECACHE)


