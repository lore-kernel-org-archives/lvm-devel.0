From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Wed, 19 Sep 2012 16:17:22 +0000 (UTC)
Subject: master - mirror: 'lvconvert --resync' should reset LV_NOTSYNCED on corelog mirror
Message-ID: <20120919161722.E104214FC@hosted02.fedoraproject.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2e04681248b7c72ce295f538d698ae644c73cc9c
Commit:        2e04681248b7c72ce295f538d698ae644c73cc9c
Parent:        290ae4791ef5eedaae2bc1cfa3645ac8073faf54
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Sep 19 11:09:32 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Sep 19 11:16:45 2012 -0500

mirror:  'lvconvert --resync' should reset LV_NOTSYNCED on corelog mirror

When reformatting the 'lvchange_resync' code in commit
05131f5853e86419d9c726faa961b8d012298d9c, a '!' should have been removed
from the condition that checks for the LV_NOTSYNCED flag on a corelog
mirror LV.  The presence of this '!' caused the LV_NOTSYNCED flag to be
cleared when it wasn't present and left when it was present.

It is not allowed to add images to a 'mirror' or 'raid1' LV if the
LV_NOTSYNCED flag is set.  We add some up-convert tests to ensure this
behavior is being enforced and that the LV_NOTSYNCED flag is being
properly cleared by 'lvchange --resync'.

(Not updating WHATS_NEW because this is intrarelease.)
---
 test/shell/lvconvert-mirror.sh |   14 ++++++++++++++
 test/shell/lvconvert-raid.sh   |   12 ++++++++++++
 tools/lvchange.c               |    2 +-
 3 files changed, 27 insertions(+), 1 deletions(-)

diff --git a/test/shell/lvconvert-mirror.sh b/test/shell/lvconvert-mirror.sh
index 4d587d9..c09b8fd 100644
--- a/test/shell/lvconvert-mirror.sh
+++ b/test/shell/lvconvert-mirror.sh
@@ -264,3 +264,17 @@ lvremove -ff $vg/$lv1
 lvcreate -l15 -n $lv1 $vg
 not lvconvert -m1 --corelog --stripes 2 $vg/$lv1
 lvremove -ff $vg
+
+# Should not be able to add images to --nosync mirror
+# but should be able to after 'lvchange --resync'
+lvcreate -m 1 -l1 -n $lv1 $vg --nosync
+not lvconvert -m +1 $vg/$lv1
+lvchange --resync -y $vg/$lv1
+lvconvert -m +1 $vg/$lv1
+lvremove -ff $vg
+
+lvcreate -m 1 --corelog -l1 -n $lv1 $vg --nosync
+not lvconvert -m +1 $vg/$lv1
+lvchange --resync -y $vg/$lv1
+lvconvert -m +1 $vg/$lv1
+lvremove -ff $vg
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index c62aee5..9c3cff6 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -79,6 +79,18 @@ for i in 1 2 3 4; do
 done
 done
 
+##############################################
+# RAID1 - shouldn't be able to add image
+#         if created '--nosync', but should
+#         be able to after 'lvchange --resync'
+##############################################
+lvcreate --type raid1 -m 1 -l 2 -n $lv1 $vg --nosync
+not lvconvert -m +1 $vg/$lv1
+lvchange --resync -y $vg/$lv1
+aux wait_for_sync $vg $lv1
+lvconvert -m +1 $vg/$lv1
+lvremove -ff $vg
+
 # 3-way to 2-way convert while specifying devices
 lvcreate --type raid1 -m 2 -l 2 -n $lv1 $vg $dev1 $dev2 $dev3
 aux wait_for_sync $vg $lv1
diff --git a/tools/lvchange.c b/tools/lvchange.c
index 0904e7b..5048cab 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -401,7 +401,7 @@ static int lvchange_resync(struct cmd_context *cmd,
 	 * worry about persistent logs.
 	 */
 	if (!seg_is_raid(seg) && !seg->log_lv) {
-		if (!(lv->status & LV_NOTSYNCED)) {
+		if (lv->status & LV_NOTSYNCED) {
 			lv->status &= ~LV_NOTSYNCED;
 			log_very_verbose("Updating logical volume \"%s\""
 					 " on disk(s)", lv->name);


