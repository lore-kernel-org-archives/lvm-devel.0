From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Mon, 31 Aug 2009 08:35:00 +0200
Subject: [PATCH 1/1] configure.in: fix --with-clvmd=all when no backends are available
In-Reply-To: <1251700500-15207-1-git-send-email-fdinitto@redhat.com>
References: <1251700500-15207-1-git-send-email-fdinitto@redhat.com>
Message-ID: <36e1fdaced74da8d39f62665ca6fae21bfb7bb5b.1251700391.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Initialize NEWCLVMD var properly so that clvmd is not built in case
there are no backends available.

Also report to the user if we were unable to detect any backend.

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 cf74d07... 55f66d8... M	configure.in
 configure.in |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/configure.in b/configure.in
index cf74d07..55f66d8 100644
--- a/configure.in
+++ b/configure.in
@@ -522,6 +522,7 @@ fi
 dnl -- If we are autodetecting, we need to re-create
 dnl -- the depedencies checks and set a proper CLVMD.
 if test x$CLVMD = xall; then
+	NEWCLVMD=none
 	if test x$HAVE_CCS = xyes && \
 	   test x$HAVE_GULM = xyes; then
 		AC_MSG_RESULT([Enabling clvmd gulm backend])
@@ -547,6 +548,9 @@ if test x$CLVMD = xall; then
 		NEWCLVMD="$NEWCLVMD,openais"
 	fi
 	CLVMD="$NEWCLVMD"
+	if test x$CLVMD = xnone; then
+		AC_MSG_RESULT([Disabling clvmd build. No backends detected.])
+	fi
 fi
 
 ################################################################################
-- 
1.5.4.3


