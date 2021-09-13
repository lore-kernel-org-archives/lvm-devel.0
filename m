From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Sep 2021 10:36:06 +0000 (GMT)
Subject: main - tests: add test for handling unknown cache settings
Message-ID: <20210913103606.F16A43858002@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=fc5f9924c74d9a2d930fe37480aeb70e9aa1c856
Commit:        fc5f9924c74d9a2d930fe37480aeb70e9aa1c856
Parent:        a8ee82ed51696b63381442106cb2298c4501fb72
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Sep 13 11:57:06 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Sep 13 12:34:41 2021 +0200

tests: add test for handling unknown cache settings

---
 test/shell/lvcreate-cache.sh | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index 4d9d75eb9..38c915ef1 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -275,6 +275,19 @@ dmsetup status | grep $vg-corigin | grep 'migration_threshold 1233'
 lvremove -f $vg
 
 
+####################################################
+# S/MQ policy does not accept random string settings
+####################################################
+
+lvcreate -L1 -n $lv1 $vg
+lvcreate -L1 -H $vg/$lv1 --cachesettings  unknown=0  |& tee out
+
+grep "not support \"unknown=0\"" out
+
+# But still the caching should proceed and LV should be available
+check lv_exists $vg/$lv1
+
+
 ##############################
 # Test things that should fail
 ##############################


