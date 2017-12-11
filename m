From: Marian Csontos <mcsontos@sourceware.org>
Date: Mon, 11 Dec 2017 07:11:45 -0500
Subject: master - configure: applib is not required by dbusd
Message-ID: <201712111211.vBBCBj54026298@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6a6c8d7b81703205a283528da5b7b8630e32d0d0
Commit:        6a6c8d7b81703205a283528da5b7b8630e32d0d0
Parent:        a64c73a979062c097395735372bbb33456d445f2
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Mon Dec 11 12:12:42 2017 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Dec 11 12:12:42 2017 +0100

configure: applib is not required by dbusd

---
 configure.in |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/configure.in b/configure.in
index 7d4f5b3..a0a47cd 100644
--- a/configure.in
+++ b/configure.in
@@ -1530,7 +1530,7 @@ if test "$PYTHON3_BINDINGS" = yes -o "$BUILD_LVMDBUSD" = yes; then
 	PYTHON3_INCDIRS=`"$PYTHON3_CONFIG" --includes`
 	PYTHON3_LIBDIRS=`"$PYTHON3_CONFIG" --libs`
 	PYTHON3DIR=$pythondir
-	PYTHON_BINDINGS=yes
+	test "$PYTHON3_BINDINGS" = yes && PYTHON_BINDINGS=yes
 fi
 
 if test "$BUILD_LVMDBUSD" = yes; then


