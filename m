From: Fabio M. Di Nitto <fabbione@fabbione.net>
Date: Thu,  8 Oct 2009 14:49:10 +0200
Subject: [PATCH 03/11] debian: force modprobe
In-Reply-To: <1255006158-8053-1-git-send-email-fabbione@fabbione.net>
References: <1255006158-8053-1-git-send-email-fabbione@fabbione.net>
Message-ID: <eaddb1c0b80c3d362cef5ced6bd556dee82b9e46.1255002311.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

From: Fabio M. Di Nitto <fdinitto@redhat.com>

well, a linux system without modprobe can't use any modules.
so this just assumes that it is available in a real system

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 45dc2c9... 06759b6... M	configure.in
 configure.in |    6 +-----
 1 files changed, 1 insertions(+), 5 deletions(-)

diff --git a/configure.in b/configure.in
index 45dc2c9..06759b6 100644
--- a/configure.in
+++ b/configure.in
@@ -974,11 +974,7 @@ if test x$UDEV_SYNC = xyes; then
 fi
 
 ################################################################################
-AC_PATH_PROG(MODPROBE_CMD, modprobe)
-
-if test x$MODPROBE_CMD != x; then
-	AC_DEFINE_UNQUOTED([MODPROBE_CMD], ["$MODPROBE_CMD"], [The path to 'modprobe', if available.])
-fi
+AC_DEFINE_UNQUOTED([MODPROBE_CMD], ["/sbin/modprobe"], [The path to 'modprobe', if available.])
 
 ################################################################################
 dnl -- dmeventd pidfile and executable path
-- 
1.5.4.3


