From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Mon,  6 Feb 2012 14:04:57 +0100
Subject: [PATCH] clvmd: fix init script to start after dlm when running with corosync >= 2.0
Message-ID: <1328533497-32202-1-git-send-email-fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: "Fabio M. Di Nitto" <fdinitto@redhat.com>

With new corosync, dlm is a standalone service provided by dlm.service and/or dlm.init.
clvmd need to start after dlm has been initialized.

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
 configure.in |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/configure.in b/configure.in
index ab04ebb..ca7019a 100644
--- a/configure.in
+++ b/configure.in
@@ -675,6 +675,15 @@ if test x$CLVMD = xall; then
 	fi
 fi
 
+dnl -- Fixup CLVMD_CMANAGERS with new corosync
+dnl -- clvmd built with corosync >= 2.0 needs dlm (either init or systemd service)
+dnl -- to be started.
+if [[ `expr x"$CLVMD" : '.*corosync.*'` != 0 ]]; then
+   if test x$HAVE_CMAP = xyes; then
+	CLVMD_CMANAGERS="$CLVMD_CMANAGERS dlm"
+   fi
+fi
+
 ################################################################################
 dnl -- clvmd pidfile
 if test "x$CLVMD" != xnone; then
-- 
1.7.7.6


