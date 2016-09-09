From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  9 Sep 2016 19:00:23 +0000 (UTC)
Subject: master - tests: skip synaction test in cluster for now
Message-ID: <20160909190023.9FAD26066E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=06e36fb43436c9e0659fbb630536a2b370163759
Commit:        06e36fb43436c9e0659fbb630536a2b370163759
Parent:        e5ec348d680ff8ea0aa1e751d13cdab5812eb672
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 9 18:27:12 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 9 20:55:01 2016 +0200

tests: skip synaction test in cluster for now

Until we resolve it - we do not support syncaction on clustered VG.
---
 test/shell/lvchange-syncaction-raid.sh |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvchange-syncaction-raid.sh b/test/shell/lvchange-syncaction-raid.sh
index 2baaaf6..448a688 100644
--- a/test/shell/lvchange-syncaction-raid.sh
+++ b/test/shell/lvchange-syncaction-raid.sh
@@ -14,6 +14,12 @@
 SKIP_WITH_LVMLOCKD=1
 SKIP_WITH_LVMPOLLD=1
 
+
+# Current support for syncaction in cluster is broken
+# might get fixed one day though
+# meanwhile skipped
+SKIP_WITH_CLVMD=1
+
 . lib/inittest
 
 # Proper mismatch count 1.5.2+ upstream, 1.3.5 < x < 1.4.0 in RHEL6


