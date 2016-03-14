From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 14 Mar 2016 22:46:58 +0000 (UTC)
Subject: master - tests: update lvconvert test
Message-ID: <20160314224658.955676112A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=746f8af2a836e662e5588a37feb29c27ed02261b
Commit:        746f8af2a836e662e5588a37feb29c27ed02261b
Parent:        0d5b9deff21991f0b26240ae4395ee12e76096c5
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 14 23:22:19 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 14 23:46:08 2016 +0100

tests: update lvconvert test

---
 test/shell/lvconvert-repair-cache.sh |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-repair-cache.sh b/test/shell/lvconvert-repair-cache.sh
index 9ef8716..60b0b5d 100644
--- a/test/shell/lvconvert-repair-cache.sh
+++ b/test/shell/lvconvert-repair-cache.sh
@@ -61,6 +61,10 @@ lvconvert -H --cachemode writethrough --cachepool $vg/cpool $lv1
 
 aux disable_dev "$dev2"
 
+# Deactivate before remove
+# FIXME: handle this while LV is alive
+lvchange -an $vg/$lv1
+
 # Check it is prompting for confirmation
 not lvconvert --uncache $vg/$lv1
 # --yes to drop when Check its prompting
@@ -72,6 +76,9 @@ lvconvert --yes --uncache $vg/$lv1
 #lvchange -ay $vg
 
 aux enable_dev "$dev2"
+
+# FIXME: temporary workaround
+lvcreate -L1 -n $lv5 $vg
 lvremove -ff $vg
 
 ##########################
@@ -92,7 +99,7 @@ lvs -a -o+seg_pe_ranges,cachemode $vg
 sync
 
 # Seriously damage cache metadata
-aux error_dev  "$dev1" 2054:2
+aux error_dev "$dev1" 2054:2
 
 # Here we usually for the 1st. notice needs_check
 check lv_attr_bit state $vg/$lv1 "c"


