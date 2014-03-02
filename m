From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun,  2 Mar 2014 20:56:05 +0000 (UTC)
Subject: master - tests: detect nc or socat
Message-ID: <20140302205605.0CC786022B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6df716332c25a49ca41f9d68e10afca68dc5dd62
Commit:        6df716332c25a49ca41f9d68e10afca68dc5dd62
Parent:        6c377f5b3c36cc0514210821b3d0b72c10d2a819
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sun Mar 2 21:48:28 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Mar 2 21:48:28 2014 +0100

tests: detect nc or socat

Since shell is not in -o pipefail mode here,
we need to generate separate failure ahead of tee.
---
 test/lib/aux.sh |   23 ++++++++++++++---------
 1 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 67e046d..f450e63 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -87,15 +87,20 @@ prepare_lvmetad() {
 }
 
 lvmetad_talk() {
-    if type -p socat >& /dev/null; then
-	socat "unix-connect:$TESTDIR/lvmetad.socket" -
-    elif echo | nc -U "$TESTDIR/lvmetad.socket"; then
-	nc -U "$TESTDIR/lvmetad.socket"
-    else
-	echo "WARNING: Neither socat nor nc -U seems to be available." 1>&2
-	echo "# failed to contact lvmetad"
-	exit 1
-    fi | tee -a lvmetad-talk.txt
+	local use=nc
+	if type -p socat >& /dev/null; then
+		use=socat
+	elif echo | not nc -U "$TESTDIR/lvmetad.socket" ; then
+		echo "WARNING: Neither socat nor nc -U seems to be available." 1>&2
+		echo "# failed to contact lvmetad"
+		return 1
+	fi
+
+	if test "$use" = nc ; then
+		nc -U "$TESTDIR/lvmetad.socket"
+	else
+		socat "unix-connect:$TESTDIR/lvmetad.socket" -
+	fi | tee -a lvmetad-talk.new
 }
 
 lvmetad_dump() {


