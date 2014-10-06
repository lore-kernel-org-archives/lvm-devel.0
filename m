From: Petr Rockai <mornfall@fedoraproject.org>
Date: Mon,  6 Oct 2014 06:14:20 +0000 (UTC)
Subject: master - test: Show an activation bug in lvcreate of a cache over raid.
Message-ID: <20141006061420.822C460FF5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=072e25a965afdd76145248edea18c3b9e36967df
Commit:        072e25a965afdd76145248edea18c3b9e36967df
Parent:        d2f901f04f76cca110475395272e70c83bea816d
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Mon Oct 6 08:11:42 2014 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Mon Oct 6 08:11:42 2014 +0200

test: Show an activation bug in lvcreate of a cache over raid.

---
 test/shell/lvcreate-cache.sh |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvcreate-cache.sh b/test/shell/lvcreate-cache.sh
index 03ff214..84c9c88 100644
--- a/test/shell/lvcreate-cache.sh
+++ b/test/shell/lvcreate-cache.sh
@@ -104,11 +104,19 @@ done
 lvcreate -aey -l 1 -n $lv1 $vg
 not lvcreate --type cache -l 2 $vg/$lv1
 
-
 # Option testing
 # --chunksize
 # --cachepolicy
 # --poolmetadatasize
 # --poolmetadataspare
 
+# TODO: creating a cache on top of active RAID appears to be broken
+lvremove -f $vg
+lvcreate -n corigin -m 1 --type raid1 -l 10 $vg
+lvcreate -n cpool --type cache $vg/corigin -l 10
+should check active $vg corigin_corig
+dmsetup table | grep ^$PREFIX | should grep corigin_corig
+lvchange --refresh $vg
+dmsetup table | grep ^$PREFIX | grep corigin_corig
+
 vgremove -ff $vg


