From: Marian Csontos <mcsontos@sourceware.org>
Date: Tue, 28 Nov 2017 03:22:10 -0500
Subject: master - tests: Die on bad argument
Message-ID: <201711280822.vAS8MAHY013510@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7665304604bad894afed5e372263e48b309927d7
Commit:        7665304604bad894afed5e372263e48b309927d7
Parent:        591ac0828af73ac9a134660a643ef234ff57c02e
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Nov 28 09:05:02 2017 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Tue Nov 28 09:21:05 2017 +0100

tests: Die on bad argument

---
 test/lib/aux.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index b8a0cc0..97111c7 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -911,6 +911,7 @@ common_dev_() {
 
 	for fromlen in "${@-0:}"; do
 		from=${fromlen%%:*}
+		test "$from" = "$fromlen" || die "Bad argument: Missing ':' in FROM:[LEN] argument"
 		len=${fromlen##*:}
 		test -n "$len" || len=$(( size - from ))
 		diff=$(( from - pos ))


