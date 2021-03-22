From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 22 Mar 2021 21:53:56 +0000 (GMT)
Subject: main - tests: avoid sleep on kill path
Message-ID: <20210322215356.618873858004@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7166bbd9c26cf5d06067cfb85eb86352b4152c3c
Commit:        7166bbd9c26cf5d06067cfb85eb86352b4152c3c
Parent:        a7d7471906501eebb6cf418ab3d0d9326805449f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 22 22:05:22 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 22 22:51:24 2021 +0100

tests: avoid sleep on kill path

Before sleeping, check if pid is still there.
---
 test/lib/aux.sh | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 2bc3da2c9..e406e47ce 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -466,12 +466,10 @@ kill_sleep_kill_() {
 		pid=$(< "$pidfile")
 		rm -f "$pidfile"
 		kill -TERM "$pid" 2>/dev/null || return 0
-		if test "$slow" -eq 0 ; then sleep .1 ; else sleep 1 ; fi
-		kill -KILL "$pid" 2>/dev/null || true
-		local wait=0
-		while ps "$pid" > /dev/null && test "$wait" -le 10; do
-			sleep .5
-			wait=$(( wait + 1 ))
+		for i in {0..10} ; do
+			ps "$pid" >/dev/null || return 0
+			if test "$slow" -eq 0 ; then sleep .2 ; else sleep 1 ; fi
+			kill -KILL "$pid" 2>/dev/null || true
 		done
 	fi
 }


