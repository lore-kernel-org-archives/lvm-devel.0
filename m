From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Thu, 27 Aug 2009 11:07:35 +0200
Subject: [PATCH 14/15] set clvmd build to default to cman locking backend
In-Reply-To: <1251364056-24149-1-git-send-email-fdinitto@redhat.com>
References: <1251364056-24149-1-git-send-email-fdinitto@redhat.com>
Message-ID: <b8bfce666620d1c5abea8deedd4646cd36a4bcbc.1251363523.git.fdinitto@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

build all, as previously suggested, does not make sense.

Allow all to be set to avoid breaking backward compatibility,
but use cman instead.

Signed-off-by: Fabio M. Di Nitto <fdinitto@redhat.com>
---
:100644 100644 df8c6e9... 496ffe6... M	configure.in
 configure.in |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/configure.in b/configure.in
index df8c6e9..496ffe6 100644
--- a/configure.in
+++ b/configure.in
@@ -334,8 +334,8 @@ AC_ARG_WITH(clvmd,
                           [TYPE=none] ],
   [ CLVMD="$withval" ],
   [ CLVMD="none" ])
-if test x$CLVMD = xyes; then
-	CLVMD=all
+if test x$CLVMD = xyes || test x$CLVMD = xall; then
+	CLVMD=cman
 fi
 AC_MSG_RESULT($CLVMD)
 
-- 
1.5.4.3


