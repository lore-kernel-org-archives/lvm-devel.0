From: Joe Thornber <thornber@sourceware.org>
Date: Mon, 30 Apr 2018 04:56:35 -0400
Subject: master - [build] uncomment 'serial 3' in an m4 file.
Message-ID: <201804300856.w3U8uZkP018933@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=475626fb6c8f2d714dcf8b7aea727430756fc571
Commit:        475626fb6c8f2d714dcf8b7aea727430756fc571
Parent:        865a9c5873a6674105010b57a7695272f626a2c6
Author:        Joe Thornber <ejt@redhat.com>
AuthorDate:    Mon Feb 12 09:22:10 2018 +0000
Committer:     Joe Thornber <ejt@redhat.com>
CommitterDate: Mon Apr 30 09:44:27 2018 +0100

[build] uncomment 'serial 3' in an m4 file.

Squashes another autoreconf warning
---
 acinclude.m4 |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/acinclude.m4 b/acinclude.m4
index cd02300..4ac611d 100644
--- a/acinclude.m4
+++ b/acinclude.m4
@@ -155,7 +155,7 @@ AC_DEFUN([AC_TRY_LDFLAGS],
 #   and this notice are preserved.  This file is offered as-is, without any
 #   warranty.
 
-#serial 3
+serial 3
 
 AC_DEFUN([AX_GCC_BUILTIN], [
     AS_VAR_PUSHDEF([ac_var], [ax_cv_have_$1])


