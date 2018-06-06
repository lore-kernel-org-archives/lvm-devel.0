From: David Teigland <teigland@sourceware.org>
Date: Wed, 6 Jun 2018 14:58:27 -0400
Subject: master - lvmlockd: fix missing lock_type null check
Message-ID: <201806061858.w56IwR65027633@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=3c657adc0a2c9026fef3186147f0d9a11b071c3b
Commit:        3c657adc0a2c9026fef3186147f0d9a11b071c3b
Parent:        c67bd8b47b755a33104e942abc49e516d2a6dace
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 6 13:56:02 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 6 13:58:03 2018 -0500

lvmlockd: fix missing lock_type null check

Missed checking if vg->lock_type is NULL in commit db8d3bdfa:
  lvmlockd: enable mirror split and merge with dlm lock_type
---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 4d58d74..53aa4f1 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -3395,7 +3395,7 @@ int lv_raid_split(struct logical_volume *lv, int yes, const char *split_name,
 
 	lvl->lv->name = split_name;
 
-	if (!strcmp(lv->vg->lock_type, "dlm"))
+	if (lv->vg->lock_type && !strcmp(lv->vg->lock_type, "dlm"))
 		lvl->lv->lock_args = lv->lock_args;
 
 	if (!vg_write(lv->vg)) {


