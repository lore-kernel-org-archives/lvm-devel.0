From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 30 Oct 2014 23:37:59 +0000 (UTC)
Subject: master - tests: update raid sync
Message-ID: <20141030233759.D718860DA0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e09ee21fd46287ed245ea086ddcf06140a83431a
Commit:        e09ee21fd46287ed245ea086ddcf06140a83431a
Parent:        47d50a8f2735a8c4496082eab5b312a596e2c2d4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 31 00:37:35 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 31 00:37:35 2014 +0100

tests: update raid sync

---
 test/shell/lvconvert-cache-raid.sh |    3 +--
 1 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/test/shell/lvconvert-cache-raid.sh b/test/shell/lvconvert-cache-raid.sh
index 174b0ec..1fcd0fe 100644
--- a/test/shell/lvconvert-cache-raid.sh
+++ b/test/shell/lvconvert-cache-raid.sh
@@ -46,11 +46,11 @@ lvremove -f $vg
 
 lvcreate -n cpool_meta -m 1 --type raid1 -l 10 $vg
 lvcreate -n cpool -m 1 --type raid1 -l 10 $vg
+aux wait_for_sync $vg cpool
 lvs -a -o+seg_pe_ranges $vg
 lvconvert --yes --type cache-pool --poolmetadata $vg/cpool_meta $vg/cpool
 lvcreate -n corigin --type cache --cachepool $vg/cpool -l 10
 
-aux wait_for_sync $vg cpool
 lvchange --syncaction repair $vg/cpool_cmeta
 lvchange --syncaction repair $vg/cpool_cdata
 
@@ -62,7 +62,6 @@ not lvconvert --splitmirrors 1 --name split_cmeta $vg/cpool_cmeta "$dev1"
 not lvconvert --splitmirrors 1 --name split_cdata $vg/cpool_cdata "$dev1"
 
 # but allow manipulating existing LVs with reserved names
-aux wait_for_sync $vg cpool
 lvconvert --splitmirrors 1 --name split_meta $vg/cpool_cmeta "$dev1"
 lvconvert --splitmirrors 1 --name split_data $vg/cpool_cdata "$dev1"
 


