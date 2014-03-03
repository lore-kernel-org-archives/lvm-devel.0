From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  3 Mar 2014 18:33:20 +0000 (UTC)
Subject: master - tests: restore .txt suffix
Message-ID: <20140303183320.8C2146179C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d739e16d85d95611a9f6edbde316c6627307d2ce
Commit:        d739e16d85d95611a9f6edbde316c6627307d2ce
Parent:        719261a33a34ff177767324089b6daa128c5c2f0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 3 19:01:30 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 3 19:30:48 2014 +0100

tests: restore .txt suffix

---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index f450e63..2d0f805 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -100,7 +100,7 @@ lvmetad_talk() {
 		nc -U "$TESTDIR/lvmetad.socket"
 	else
 		socat "unix-connect:$TESTDIR/lvmetad.socket" -
-	fi | tee -a lvmetad-talk.new
+	fi | tee -a lvmetad-talk.txt
 }
 
 lvmetad_dump() {


