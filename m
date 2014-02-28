From: Petr Rockai <mornfall@fedoraproject.org>
Date: Fri, 28 Feb 2014 22:43:25 +0000 (UTC)
Subject: master - test: Fix the failing branch in aux lvmetad_talk.
Message-ID: <20140228224325.7433F60FF7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6733ac86d717df0bc8de5ea0ae59f9d017f9e208
Commit:        6733ac86d717df0bc8de5ea0ae59f9d017f9e208
Parent:        fb003cdfd5eee1d67887cd2136630cc36bba2cbf
Author:        Petr Rockai <me@mornfall.net>
AuthorDate:    Fri Feb 28 23:30:17 2014 +0100
Committer:     Petr Rockai <me@mornfall.net>
CommitterDate: Fri Feb 28 23:30:17 2014 +0100

test: Fix the failing branch in aux lvmetad_talk.

---
 test/lib/aux.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/lib/aux.sh b/test/lib/aux.sh
index ab3fc05..5ae40e8 100644
--- a/test/lib/aux.sh
+++ b/test/lib/aux.sh
@@ -94,7 +94,7 @@ lvmetad_talk() {
     else
 	echo "WARNING: Neither socat nor nc -U seems to be available." 1>&2
 	echo "# failed to contact lvmetad"
-	return 1
+	exit 1
     fi | tee -a lvmetad-talk.txt
 }
 


