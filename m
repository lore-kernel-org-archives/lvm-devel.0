From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed, 17 Jan 2018 08:46:53 -0500
Subject: master - tests: check preserved exclusivness of snapshot merge
Message-ID: <201801171346.w0HDkrmM030061@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8ebd45fde759c438e854d6b4f02f0e9803094fea
Commit:        8ebd45fde759c438e854d6b4f02f0e9803094fea
Parent:        8c7ec44bf0fb23e2c5e426c5d07b02e3d25f5b59
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 15 13:29:14 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jan 17 14:45:48 2018 +0100

tests: check preserved exclusivness of snapshot merge

Detect if origin remains exclusively activated after merging.
---
 test/shell/snapshot-merge.sh |    4 ++++
 test/shell/thin-merge.sh     |    9 +++++++++
 2 files changed, 13 insertions(+), 0 deletions(-)

diff --git a/test/shell/snapshot-merge.sh b/test/shell/snapshot-merge.sh
index 9d0a264..41e7b00 100644
--- a/test/shell/snapshot-merge.sh
+++ b/test/shell/snapshot-merge.sh
@@ -54,7 +54,11 @@ setup_merge_ $vg $lv1
 
 # make sure lvconvert --merge requires explicit LV listing
 not lvconvert --merge
+
+# check exclusive lock is preserved after merge
+check lv_field "$vg/$lv1" lv_active_exclusively "active exclusively"
 lvconvert --merge "$vg/$(snap_lv_name_ "$lv1")"
+check lv_field "$vg/$lv1" lv_active_exclusively "active exclusively"
 lvremove -f $vg/$lv1
 
 setup_merge_ $vg $lv1
diff --git a/test/shell/thin-merge.sh b/test/shell/thin-merge.sh
index 3abda40..24dec96 100644
--- a/test/shell/thin-merge.sh
+++ b/test/shell/thin-merge.sh
@@ -30,6 +30,15 @@ aux have_thin 1 0 0 || skip
 aux prepare_vg 2
 
 lvcreate -T -L8M $vg/pool -V10M -n $lv1
+lvcreate -s -K -n snap $vg/$lv1
+# check exclusive lock is preserved after merge
+check lv_field "$vg/$lv1" lv_active_exclusively "active exclusively"
+lvconvert --merge $vg/snap
+check lv_field "$vg/$lv1" lv_active_exclusively "active exclusively"
+lvremove -ff $vg
+
+
+lvcreate -T -L8M $vg/pool -V10M -n $lv1
 lvchange --addtag tagL $vg/$lv1
 
 mkdir mnt


