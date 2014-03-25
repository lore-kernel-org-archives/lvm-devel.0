From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Mar 2014 23:06:44 +0000 (UTC)
Subject: master - tests: pass list devs to allocate from
Message-ID: <20140325230644.213E961055@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=5b900dbef53d18dcc9bfcf939ffe991e5ec9fbb1
Commit:        5b900dbef53d18dcc9bfcf939ffe991e5ec9fbb1
Parent:        1259ae59540b3e9c5ef582a6e472e17258ee36dc
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 25 23:56:15 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Mar 26 00:05:46 2014 +0100

tests: pass list devs to allocate from

---
 test/shell/lvconvert-repair-policy.sh |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-repair-policy.sh b/test/shell/lvconvert-repair-policy.sh
index cefb0ea..9d71b66 100644
--- a/test/shell/lvconvert-repair-policy.sh
+++ b/test/shell/lvconvert-repair-policy.sh
@@ -30,7 +30,7 @@ repair_() {
 	lvconvert --repair --use-policies --config "$1" $vg/mirror
 }
 
-lvcreate -aey --type mirror -m 1 -L 1 -n mirror $vg
+lvcreate -aey --type mirror -m 1 --ignoremonitoring -l 2 -n mirror $vg "$dev1" "$dev2" "$dev3:0"
 lvchange -a n $vg/mirror
 
 # Fail a leg of a mirror.


