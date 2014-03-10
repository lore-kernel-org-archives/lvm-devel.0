From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Mar 2014 11:27:36 +0000 (UTC)
Subject: master - tests: dmeventd valgrind testing
Message-ID: <20140310112736.184316039D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5dc9402774efb99ffea95d7f5435f36d68aa5077
Commit:        5dc9402774efb99ffea95d7f5435f36d68aa5077
Parent:        c7262d5b383091e874d5a00ac266819b5eda649b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Mar 8 23:19:26 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 10 12:24:11 2014 +0100

tests: dmeventd valgrind testing

---
 test/lib/aux.sh |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 4b4662c..53d0fc7 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -62,11 +62,14 @@ prepare_dmeventd() {
 
 	lvmconf "activation/monitoring = 1"
 
-	dmeventd -f "$@" &
+	local run_valgrind=
+	test "${LVM_VALGRIND_DMEVENTD:-0}" -eq 0 || run_valgrind="run_valgrind"
+	$run_valgrind dmeventd -f "$@" &
 	echo $! > LOCAL_DMEVENTD
 
 	# FIXME wait for pipe in /var/run instead
-	sleep .3
+	while ! test -e "/var/run/dmeventd.pid"; do echo -n .; sleep .2; done # wait for the socket
+	echo ok
 }
 
 prepare_lvmetad() {
@@ -217,8 +220,7 @@ teardown() {
 
 	echo -n .
 
-	pgrep dmeventd || true
-	test ! -s LOCAL_DMEVENTD || kill -9 "$(cat LOCAL_DMEVENTD)" || true
+	kill_sleep_kill_ LOCAL_DMEVENTD ${LVM_VALGRIND_DMEVENTD:-0}
 
 	echo -n .
 


