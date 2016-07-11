From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 11 Jul 2016 15:30:20 +0000 (UTC)
Subject: master - lvconvert: remove some FIXME comments
Message-ID: <20160711153020.AF4C7605F7@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9f7e8f22dc42576875a436dee0034d37f89c468c
Commit:        9f7e8f22dc42576875a436dee0034d37f89c468c
Parent:        c526c327d7352e60eb19a739a2f394e2744c5629
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Jul 8 15:31:27 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jul 11 10:29:10 2016 -0500

lvconvert: remove some FIXME comments

---
 tools/lvconvert.c |    6 ------
 1 files changed, 0 insertions(+), 6 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 0319601..72dc381 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -3653,8 +3653,6 @@ static int _convert_mirror_linear(struct cmd_context *cmd, struct logical_volume
 /*
  * Convert mirror LV to raid1 LV.
  * lvconvert --type raid1 LV
- *
- * FIXME: this is not yet implemented in the raid code.
  */
 
 static int _convert_mirror_raid(struct cmd_context *cmd, struct logical_volume *lv,
@@ -3846,8 +3844,6 @@ static int _convert_raid_raid(struct cmd_context *cmd, struct logical_volume *lv
 /*
  * Convert a raid* LV to a striped LV.
  * lvconvert --type striped LV
- *
- * FIXME: this is not yet implemented in the raid code.
  */
 
 static int _convert_raid_striped(struct cmd_context *cmd, struct logical_volume *lv,
@@ -3859,8 +3855,6 @@ static int _convert_raid_striped(struct cmd_context *cmd, struct logical_volume
 /*
  * Convert a raid* LV to a linear LV.
  * lvconvert --type linear LV
- *
- * FIXME: this is not yet implemented in the raid code.
  */
 
 static int _convert_raid_linear(struct cmd_context *cmd, struct logical_volume *lv,


