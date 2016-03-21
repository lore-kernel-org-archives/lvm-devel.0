From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Mon, 21 Mar 2016 14:38:24 +0000 (UTC)
Subject: master - test: Turn on dbus test
Message-ID: <20160321143824.C8E7260DC8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ca7bac53cf0b3b64bdfa375085fc1535589ab1eb
Commit:        ca7bac53cf0b3b64bdfa375085fc1535589ab1eb
Parent:        f231bdb20bdc885460dfc49db744147bb1bc90da
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Tue Feb 23 09:00:35 2016 +0100
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Mon Mar 21 15:22:58 2016 +0100

test: Turn on dbus test

(cherry picked from commit f1ea96c6c1dc6414169bda1a18cf14cd9ebb1493)
---
 test/api/dbustest.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/api/dbustest.sh b/test/api/dbustest.sh
index 039689d..dd9b23d 100644
--- a/test/api/dbustest.sh
+++ b/test/api/dbustest.sh
@@ -17,7 +17,7 @@ SKIP_WITH_CLVMD=1
 . lib/inittest
 
 # Will default to skip until we can get this reviewed
-skip
+#skip
 
 aux prepare_pvs 6
 


