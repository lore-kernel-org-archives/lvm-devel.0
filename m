From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Wed, 23 Mar 2016 11:30:51 +0000 (UTC)
Subject: master - test: Remove pidfile after killing the process
Message-ID: <20160323113051.2E3F760D17@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1b0775916b78e1270872d3649a2c9abf0a1bb790
Commit:        1b0775916b78e1270872d3649a2c9abf0a1bb790
Parent:        bb93a28bc1d8b284c13ca5e5c925ce5b67d12204
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Wed Mar 23 12:18:08 2016 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Wed Mar 23 12:25:18 2016 +0100

test: Remove pidfile after killing the process

Though unlikely keeping files in place may result in random process
killed.
---
 test/lib/aux.sh |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index 4f5daaf..2767880 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -435,6 +435,7 @@ kill_sleep_kill_() {
 	slow=$2
 	if test -s $pidfile ; then
 		pid=$(< $pidfile)
+		rm -f $pidfile
 		kill -TERM $pid 2>/dev/null || return 0
 		if test $slow -eq 0 ; then sleep .1 ; else sleep 1 ; fi
 		kill -KILL $pid 2>/dev/null || true


