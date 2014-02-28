From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 10:26:37 +0000 (UTC)
Subject: master - test: Add lvmetad_talk and lvmetad_dump to aux.
Message-ID: <20140228102637.70A3D60FF2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f3b9fe60242456f0e89a30e89b2f2849a78bb9e8
Commit:        f3b9fe60242456f0e89a30e89b2f2849a78bb9e8
Parent:        8e814eb8997d6aa5e3169d909a3ce1d8d2536897
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Fri Feb 28 11:18:33 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 11:23:53 2014 +0100

test: Add lvmetad_talk and lvmetad_dump to aux.

---
 test/lib/aux.sh            |   16 ++++++++++++++++
 test/shell/lvmetad-dump.sh |   20 ++------------------
 2 files changed, 18 insertions(+), 18 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index de14253..ab3fc05 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -86,6 +86,22 @@ prepare_lvmetad() {
 	echo ok
 }
 
+lvmetad_talk() {
+    if type -p socat >& /dev/null; then
+	socat "unix-connect:$TESTDIR/lvmetad.socket" -
+    elif echo | nc -U "$TESTDIR/lvmetad.socket"; then
+	nc -U "$TESTDIR/lvmetad.socket"
+    else
+	echo "WARNING: Neither socat nor nc -U seems to be available." 1>&2
+	echo "# failed to contact lvmetad"
+	return 1
+    fi | tee -a lvmetad-talk.txt
+}
+
+lvmetad_dump() {
+    (echo 'request="dump"'; echo '##') | lvmetad_talk "$@"
+}
+
 notify_lvmetad() {
 	if test -e LOCAL_LVMETAD; then
 		pvscan --cache "$@" || true
diff --git a/test/shell/lvmetad-dump.sh b/test/shell/lvmetad-dump.sh
index 462de1c..9c9cd2b 100644
--- a/test/shell/lvmetad-dump.sh
+++ b/test/shell/lvmetad-dump.sh
@@ -16,24 +16,8 @@ aux prepare_pvs 2
 vgcreate $vg1 $dev1 $dev2
 lvcreate -n bar -l 1 $vg1
 
-lvmetad_talk() {
-    if type -p socat >& /dev/null; then
-	socat "unix-connect:$1" -
-    elif echo | nc -U "$1"; then
-	nc -U "$1"
-    else
-	echo "WARNING: Neither socat nor nc -U seems to be available." 1>&2
-	echo "# DUMP FAILED"
-	return 1
-    fi
-}
-
-lvmetad_dump() {
-    (echo 'request="dump"'; echo '##') | lvmetad_talk "$@"
-}
-
-(echo | lvmetad_talk ./lvmetad.socket) || skip
-lvmetad_dump ./lvmetad.socket | tee lvmetad.txt
+(echo | aux lvmetad_talk) || skip
+aux lvmetad_dump | tee lvmetad.txt
 
 grep $vg1 lvmetad.txt
 


