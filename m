From: Milan Broz <mbroz@redhat.com>
Date: Fri, 22 Jan 2010 16:59:58 +0100
Subject: [PATCH] Fix cmirrord init script
Message-ID: <1264175998-32318-1-git-send-email-mbroz@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

 - break cannot be used here
 - remove CLVMDOPTS
 - add echo to stop call
---
 scripts/cmirrord_init_red_hat.in |    9 +++------
 1 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/scripts/cmirrord_init_red_hat.in b/scripts/cmirrord_init_red_hat.in
index 997495a..ab3b7fb 100755
--- a/scripts/cmirrord_init_red_hat.in
+++ b/scripts/cmirrord_init_red_hat.in
@@ -24,14 +24,10 @@ start()
 	if ! pidof $DAEMON > /dev/null 
 	then 
 		echo -n "Starting $DAEMON: "
-		daemon $DAEMON $CLVMDOPTS
+		daemon $DAEMON
 		rtrn=$?
 		echo
-		if [ $rtrn -ne 0 ]
-		then
-			break
-		fi
-	fi      
+	fi
 
 	return $rtrn
 }
@@ -41,6 +37,7 @@ stop()
 	echo -n "Stopping $DAEMON:"
 	killproc $DAEMON -TERM
 	rtrn=$?
+	echo
 
 	return $rtrn
 }
-- 
1.6.6


