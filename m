From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Thu, 27 Aug 2009 11:07:24 +0200
Subject: [PATCH 03/15] configure.in: Add sanity check for requested clvmd build
In-Reply-To: <1251364056-24149-1-git-send-email-fdinitto@redhat.com>
References: <1251364056-24149-1-git-send-email-fdinitto@redhat.com>
Message-ID: <125f74b28d6f7a7dd88917acb9010972aada6db5.1251363523.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Start restricting the combinations of backends that can be built
within clvmd.

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 c58bb95... a6d90e7... M	configure.in
 configure.in |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/configure.in b/configure.in
index c58bb95..a6d90e7 100644
--- a/configure.in
+++ b/configure.in
@@ -358,6 +358,14 @@ if [[ `expr x"$CLVMD" : '.*cman.*'` != 0 ]]; then
 	BUILDCMAN=yes
 fi
 
+dnl -- sanity check around user selection
+if test x$BUILDGULM = xyes; then
+	if test x$BUILDCOROSYNC = xyes || \
+	   test x$BUILDOPENAIS = xyes; then
+		AC_MSG_ERROR([requested clvmd configuration is not valid])
+	fi
+fi
+
 dnl -- Look for corosync libraries if required.
 if [[ "x$CLVMD" = xall -o `expr x"$CLVMD" : '.*corosync.*'` != 0 ]]; then
 	PKG_CHECK_MODULES(QUORUM, libquorum, [],
-- 
1.5.4.3


