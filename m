From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 21 May 2014 22:56:10 +0000 (UTC)
Subject: master - tests: more pvchange tests
Message-ID: <20140521225610.008B460DF8@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=37b4dc777590ed0e6771833dce4c0727dfc72465
Commit:        37b4dc777590ed0e6771833dce4c0727dfc72465
Parent:        79f466524377f08ff4a736f159eac44f9923f4f1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed May 21 23:13:19 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed May 21 23:14:42 2014 +0200

tests: more pvchange tests

---
 test/shell/pvchange-usage.sh |   15 ++++++++++++---
 1 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/test/shell/pvchange-usage.sh b/test/shell/pvchange-usage.sh
index 00489bd..71388de 100644
--- a/test/shell/pvchange-usage.sh
+++ b/test/shell/pvchange-usage.sh
@@ -77,7 +77,11 @@ check pvlv_counts $vg1 2 0 0
 
 # some args are needed
 invalid pvchange
-
+# some PV needed
+invalid pvchange --addtag tag
+invalid pvchange --deltag tag
+# some --all & PV can go together
+invalid pvchange -a "$dev1" --addtag tag
 # '-a' needs more params
 invalid pvchange -a
 # '-a' is searching for devs, so specifying device is invalid
@@ -91,6 +95,11 @@ not pvchange -u "$dev1"
 
 vgremove -f $vg1
 
-# "pvchange reject --addtag to lvm1 pv"
+# cannot change PV tag to PV that is not in VG"
+fail pvchange "$dev1" --addtag test
+fail pvchange "$dev1" --deltag test
+
+# cannot add PV tag to lvm1 format
 pvcreate -M1 "$dev1"
-not pvchange "$dev1" --addtag test
+vgcreate -M1 $vg1 "$dev1"
+fail pvchange "$dev1" --addtag test


