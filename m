From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 10 Nov 2014 21:06:48 +0000 (UTC)
Subject: master - tests: cache snapshot
Message-ID: <20141110210648.D5A6C60789@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=10ebabdd2a8c686d814205fd923229572eebdd3a
Commit:        10ebabdd2a8c686d814205fd923229572eebdd3a
Parent:        02f49caa3599d74ff9ef850d76fec69569ef9621
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 4 23:24:56 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Nov 10 22:05:49 2014 +0100

tests: cache snapshot

---
 test/shell/lvconvert-cache.sh |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-cache.sh b/test/shell/lvconvert-cache.sh
index 4f266ba..ed414ed 100644
--- a/test/shell/lvconvert-cache.sh
+++ b/test/shell/lvconvert-cache.sh
@@ -17,6 +17,14 @@ aux have_cache 1 3 0 || skip
 
 aux prepare_vg 5 80
 
+lvcreate --type cache-pool -an -v -L 2 -n cpool $vg
+lvcreate -H -L 4 -n corigin --cachepool $vg/cpool
+
+fail lvcreate -s -L2 $vg/corigin
+fail lvcreate -s -L2 $vg/cpool
+fail lvcreate -s -L2 $vg/cpool_cdata
+fail lvcreate -s -L2 $vg/cpool_cmeta
+
 ###########################
 # Check regular converion #
 ###########################


