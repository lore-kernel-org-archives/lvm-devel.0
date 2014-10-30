From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 30 Oct 2014 23:33:11 +0000 (UTC)
Subject: master - tests: wait for raid sync
Message-ID: <20141030233311.C528B60DD4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=47d50a8f2735a8c4496082eab5b312a596e2c2d4
Commit:        47d50a8f2735a8c4496082eab5b312a596e2c2d4
Parent:        e7c130430a2b232bdf062f8fb3064899b176986b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 31 00:31:54 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 31 00:31:54 2014 +0100

tests: wait for raid sync

---
 test/shell/lvconvert-cache-raid.sh |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-cache-raid.sh b/test/shell/lvconvert-cache-raid.sh
index 16dd38e..174b0ec 100644
--- a/test/shell/lvconvert-cache-raid.sh
+++ b/test/shell/lvconvert-cache-raid.sh
@@ -50,6 +50,7 @@ lvs -a -o+seg_pe_ranges $vg
 lvconvert --yes --type cache-pool --poolmetadata $vg/cpool_meta $vg/cpool
 lvcreate -n corigin --type cache --cachepool $vg/cpool -l 10
 
+aux wait_for_sync $vg cpool
 lvchange --syncaction repair $vg/cpool_cmeta
 lvchange --syncaction repair $vg/cpool_cdata
 
@@ -61,6 +62,7 @@ not lvconvert --splitmirrors 1 --name split_cmeta $vg/cpool_cmeta "$dev1"
 not lvconvert --splitmirrors 1 --name split_cdata $vg/cpool_cdata "$dev1"
 
 # but allow manipulating existing LVs with reserved names
+aux wait_for_sync $vg cpool
 lvconvert --splitmirrors 1 --name split_meta $vg/cpool_cmeta "$dev1"
 lvconvert --splitmirrors 1 --name split_data $vg/cpool_cdata "$dev1"
 


