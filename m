From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Thu, 27 Aug 2009 11:07:23 +0200
Subject: [PATCH 02/15] configure.in: define clvmd build types
In-Reply-To: <1251364056-24149-1-git-send-email-fdinitto@redhat.com>
References: <1251364056-24149-1-git-send-email-fdinitto@redhat.com>
Message-ID: <fbd116febb183e0c1392488efc1e3366dcdfc54c.1251363523.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

set variables we will use later on to do multiple sanity
checks on the clvmd build

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 f9e5d8d... c58bb95... M	configure.in
 configure.in |   14 ++++++++++++++
 1 files changed, 14 insertions(+), 0 deletions(-)

diff --git a/configure.in b/configure.in
index f9e5d8d..c58bb95 100644
--- a/configure.in
+++ b/configure.in
@@ -344,6 +344,20 @@ if  test x$CLVMD != xnone && test x$CLUSTER = xnone; then
 	CLUSTER=internal
 fi
 
+dnl -- define build types
+if [[ `expr x"$CLVMD" : '.*gulm.*'` != 0 ]]; then
+	BUILDGULM=yes
+fi
+if [[ `expr x"$CLVMD" : '.*corosync.*'` != 0 ]]; then
+	BUILDCOROSYNC=yes
+fi
+if [[ `expr x"$CLVMD" : '.*openais.*'` != 0 ]]; then
+	BUILDOPENAIS=yes
+fi
+if [[ `expr x"$CLVMD" : '.*cman.*'` != 0 ]]; then
+	BUILDCMAN=yes
+fi
+
 dnl -- Look for corosync libraries if required.
 if [[ "x$CLVMD" = xall -o `expr x"$CLVMD" : '.*corosync.*'` != 0 ]]; then
 	PKG_CHECK_MODULES(QUORUM, libquorum, [],
-- 
1.5.4.3


