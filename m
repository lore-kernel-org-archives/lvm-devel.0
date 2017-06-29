From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 29 Jun 2017 16:27:45 -0400
Subject: master - tests: aux.sh use pgrep
Message-ID: <201706292027.v5TKRj9j026678@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=474e3cd66d7be358f54674f1ea449adf47ab1a61
Commit:        474e3cd66d7be358f54674f1ea449adf47ab1a61
Parent:        72a58ce4b0f68f6e45ae30606fe5af21caa42b43
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 29 00:04:47 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 29 22:23:16 2017 +0200

tests: aux.sh use pgrep

---
 test/lib/aux.sh |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 680adb2..863f3da 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -309,7 +309,7 @@ prepare_lvmdbusd() {
 
         # FIXME: This is not correct! Daemon is auto started.
 	echo "checking lvmdbusd is NOT running..."
-	if ps -elf | grep lvmdbusd | grep python3; then
+	if pgrep lvmdbusd | grep python3; then
 		echo "Cannot run while existing lvmdbusd process exists"
 		return 1
 	fi
@@ -343,7 +343,7 @@ prepare_lvmdbusd() {
 
 	sleep 1
 	echo "checking lvmdbusd IS running..."
-	if ! ps -elf | grep lvmdbusd | grep python3; then
+	if ! pgrep lvmdbusd | grep python3; then
 		echo "Failed to start lvmdbusd daemon"
 		return 1
 	fi


