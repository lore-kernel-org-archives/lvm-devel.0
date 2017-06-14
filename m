From: Jonathan Brassow <jbrassow@sourceware.org>
Date: Wed, 14 Jun 2017 15:52:39 -0400
Subject: master - clean-ups: remove unused var, add 'static' for local fn, adjust test
Message-ID: <201706141952.v5EJqdmF029786@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=1f57a5263e3ef2dd95e91ea39a40e45993d31028
Commit:        1f57a5263e3ef2dd95e91ea39a40e45993d31028
Parent:        ddb14b6b05e0f75a97ab8ab1ed99091268c239ba
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Wed Jun 14 14:49:42 2017 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Wed Jun 14 14:49:42 2017 -0500

clean-ups:  remove unused var, add 'static' for local fn, adjust test

For the test clean-up, I was providing too many devices to the first
command - possibly allowing it to allocate in the wrong place.  I was
also not providing a device for the second command - virtually ensuring
the test was not performing correctly at times.
---
 lib/metadata/raid_manip.c    |    3 +--
 test/shell/lvconvert-raid.sh |    4 ++--
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 52def78..dca5ba3 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2877,7 +2877,6 @@ static int _raid_allow_extraction(struct logical_volume *lv,
 	char *dev_health;
 	char *sync_action;
 	struct lv_segment *seg = first_seg(lv);
-	struct cmd_context *cmd = lv->vg->cmd;
 
 	/* If in-sync or hanlding repairs, allow to proceed. */
 	if (_raid_in_sync(lv) || lv->vg->cmd->handles_missing_pvs)
@@ -6510,7 +6509,7 @@ has_enough_space:
  * Returns: 1 if the state is detected, 0 otherwise.
  * FIXME: would be better to return -1,0,1 to allow error report.
  */
-int _lv_raid_has_primary_failure_on_recover(struct logical_volume *lv)
+static int _lv_raid_has_primary_failure_on_recover(struct logical_volume *lv)
 {
 	char *tmp_dev_health;
 	char *tmp_sync_action;
diff --git a/test/shell/lvconvert-raid.sh b/test/shell/lvconvert-raid.sh
index fba7864..6c05c67 100644
--- a/test/shell/lvconvert-raid.sh
+++ b/test/shell/lvconvert-raid.sh
@@ -228,9 +228,9 @@ done
 #  - DO allow removal of secondaries while syncing
 ###########################################
 aux delay_dev $dev2 0 100
-lvcreate -aey -l 2 -n $lv1 $vg $dev1 $dev2
+lvcreate -aey -l 2 -n $lv1 $vg $dev1
 lvconvert -y -m 1 $vg/$lv1 \
-	--config 'global { mirror_segtype_default = "raid1" }'
+	--config 'global { mirror_segtype_default = "raid1" }' $dev2
 lvs --noheadings -o attr $vg/$lv1 | grep '^[[:space:]]*r'
 not lvconvert --yes -m 0 $vg/$lv1 $dev1
 lvconvert --yes -m 0 $vg/$lv1 $dev2


