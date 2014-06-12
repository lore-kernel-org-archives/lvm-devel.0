From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 12 Jun 2014 09:56:48 +0000 (UTC)
Subject: master - test: pvs bz1108394
Message-ID: <20140612095648.32AA560E45@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cf4d5ead0210aa12dfd73fed2061d4d9febce827
Commit:        cf4d5ead0210aa12dfd73fed2061d4d9febce827
Parent:        eb316fec33e3866b92357a8aab1dd7a3c4b86075
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jun 12 11:31:21 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jun 12 11:56:06 2014 +0200

test: pvs bz1108394

---
 test/shell/pvremove-usage.sh |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/test/shell/pvremove-usage.sh b/test/shell/pvremove-usage.sh
index 3ebfd15..52d26a6 100644
--- a/test/shell/pvremove-usage.sh
+++ b/test/shell/pvremove-usage.sh
@@ -23,6 +23,10 @@ pvremove "$dev2"
 # failing, but still removing everything what can be removed
 # is somewhat odd as default, what do we have -f for?
 pvs | not grep "$dev2"
+pvs -a | grep "$dev2"
+# bz1108394 no crash on nonPV label listing
+pvs -a -o+devices
+
 pvcreate  --metadatacopies 0 "$dev2"
 
 # check pvremove refuses to remove pv in a vg


