From: Marian Csontos <mcsontos@fedoraproject.org>
Date: Thu, 31 Jul 2014 20:57:55 +0000 (UTC)
Subject: master - test: Skip lvextend-thin when thin not available
Message-ID: <20140731205755.C68586016D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0dc3684b872fa1f225e06deeb0136d1ef66d4c1e
Commit:        0dc3684b872fa1f225e06deeb0136d1ef66d4c1e
Parent:        ef8599798069b2c49aa1c296e6f8b050458b6aeb
Author:        Marian Csontos <mcsontos@redhat.com>
AuthorDate:    Thu Jul 31 22:56:19 2014 +0200
Committer:     Marian Csontos <mcsontos@redhat.com>
CommitterDate: Thu Jul 31 22:56:19 2014 +0200

test: Skip lvextend-thin when thin not available

---
 test/shell/lvextend-thin.sh |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvextend-thin.sh b/test/shell/lvextend-thin.sh
index 0d5a2f5..1a0b440 100644
--- a/test/shell/lvextend-thin.sh
+++ b/test/shell/lvextend-thin.sh
@@ -11,6 +11,8 @@
 
 . lib/inittest
 
+aux have_thin 1 0 0 || skip
+
 aux prepare_vg 3
 lvcreate -i2 -l2 -T $vg/pool2
 lvextend -l+2 $vg/pool2 $dev2 $dev3


