From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 17 Jun 2014 16:35:20 +0000 (UTC)
Subject: master - test: fix report_select test to work in cluster
Message-ID: <20140617163520.CC39160D68@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b16f5633ab199dedfd25f08562f686a6fb4aba9d
Commit:        b16f5633ab199dedfd25f08562f686a6fb4aba9d
Parent:        ef43a50926d0590910798dd366f6b8da548b05a3
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jun 17 18:28:27 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jun 17 18:34:46 2014 +0200

test: fix report_select test to work in cluster

The snapshot LV is used to check selection of percent values.
The orig volume must be activated exclusively in cluster.
---
 test/shell/report-select.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/report-select.sh b/test/shell/report-select.sh
index 13d18fc..8df1d27 100644
--- a/test/shell/report-select.sh
+++ b/test/shell/report-select.sh
@@ -32,7 +32,7 @@ lvcreate --addtag 'lv_tag2.-+/=!:&#' --addtag "lv_tag1" -L8m -n "vol1" $vg1
 lvcreate --addtag "lv_tag1" -L4m -n "vol2" $vg1
 lvcreate --readahead 512 --addtag "lv_tag1" -L16m -n "abc" $vg2
 lvcreate --readahead 512 -My --minor 254 -L4m -n "xyz" $vg3
-lvcreate -L4m -n "orig" $vg3
+lvcreate -L4m -aey -n "orig" $vg3
 lvcreate -L4m -s "$vg3/orig" -n "snap"
 
 OUT_LOG_FILE="out"


