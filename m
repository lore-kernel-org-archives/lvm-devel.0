From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 14 Nov 2014 17:17:45 +0000 (UTC)
Subject: master - tests: explicit raid sync
Message-ID: <20141114171745.54B6760DCE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=27182e1ddb21d3a90559b7a848c422eb2a443cfd
Commit:        27182e1ddb21d3a90559b7a848c422eb2a443cfd
Parent:        fd32bb1991d8323d655361d19a636e29c6aa62c3
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 13 21:52:02 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 14 18:12:44 2014 +0100

tests: explicit raid sync

---
 test/shell/lvconvert-cache-raid.sh |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/test/shell/lvconvert-cache-raid.sh b/test/shell/lvconvert-cache-raid.sh
index 1fcd0fe..faab251 100644
--- a/test/shell/lvconvert-cache-raid.sh
+++ b/test/shell/lvconvert-cache-raid.sh
@@ -46,6 +46,7 @@ lvremove -f $vg
 
 lvcreate -n cpool_meta -m 1 --type raid1 -l 10 $vg
 lvcreate -n cpool -m 1 --type raid1 -l 10 $vg
+aux wait_for_sync $vg cpool_meta
 aux wait_for_sync $vg cpool
 lvs -a -o+seg_pe_ranges $vg
 lvconvert --yes --type cache-pool --poolmetadata $vg/cpool_meta $vg/cpool
@@ -62,6 +63,8 @@ not lvconvert --splitmirrors 1 --name split_cmeta $vg/cpool_cmeta "$dev1"
 not lvconvert --splitmirrors 1 --name split_cdata $vg/cpool_cdata "$dev1"
 
 # but allow manipulating existing LVs with reserved names
+aux wait_for_sync $vg cpool_cmeta
+aux wait_for_sync $vg cpool_cdata
 lvconvert --splitmirrors 1 --name split_meta $vg/cpool_cmeta "$dev1"
 lvconvert --splitmirrors 1 --name split_data $vg/cpool_cdata "$dev1"
 


