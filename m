From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 12 Dec 2017 08:19:42 -0500
Subject: master - test: Fix condition when detecting lvmdbusd
Message-ID: <201712121319.vBCDJgWC014616@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=15ccea71116f4c0a587aaa0ed25dc1d8d98c0c7f
Commit:        15ccea71116f4c0a587aaa0ed25dc1d8d98c0c7f
Parent:        c5ef76bf27337406d48990acbfdaa869fd30f47b
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Dec 12 14:18:27 2017 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Dec 12 14:19:22 2017 +0100

test: Fix condition when detecting lvmdbusd

---
 test/lib/aux.sh |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index a436f84..6bc7bd4 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -324,10 +324,13 @@ prepare_lvmdbusd() {
 	echo ok
 
 	# skip if we don't have our own lvmdbusd...
+	echo -n "## find lvmdbusd to use..."
 	if test -z "${installed_testsuite+varset}"; then
 		# NOTE: this is always present - additional checks are needed:
 		daemon="$abs_top_builddir/daemons/lvmdbusd/lvmdbusd"
-		if ! test -x "$daemon" && chmod ugo+x "$daemon"; then
+		if test -x "$daemon" || chmod ugo+x "$daemon"; then
+			echo "$daemon"
+		else
 			echo "Failed to make '$daemon' executable">&2
 			return 1
 		fi
@@ -335,6 +338,7 @@ prepare_lvmdbusd() {
 		export PYTHONPATH="$abs_top_builddir/daemons"
 	else
 		daemon=$(which lvmdbusd || :)
+		echo "$daemon"
 	fi
 	test -x "$daemon" || skip "The lvmdbusd daemon is missing"
 	which python3 >/dev/null || skip "Missing python3"


