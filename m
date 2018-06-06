From: David Teigland <teigland@sourceware.org>
Date: Wed, 6 Jun 2018 14:57:44 -0400
Subject: 2018-06-01-stable - lvmlockd: fix missing lock_type null check
Message-ID: <201806061857.w56IviDu027605@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=347c807f86a61563e2a39c4b950ad124f9e30d66
Commit:        347c807f86a61563e2a39c4b950ad124f9e30d66
Parent:        1e5f6887b1d31762dd5fcfd7f53c2ca24646aece
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Jun 6 13:56:02 2018 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Jun 6 13:56:02 2018 -0500

lvmlockd: fix missing lock_type null check

Missed checking if vg->lock_type is NULL in commit db8d3bdfa:
  lvmlockd: enable mirror split and merge with dlm lock_type
---
 lib/metadata/raid_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 0c631b4..605700b 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -3395,7 +3395,7 @@ int lv_raid_split(struct logical_volume *lv, int yes, const char *split_name,
 
 	lvl->lv->name = split_name;
 
-	if (!strcmp(lv->vg->lock_type, "dlm"))
+	if (lv->vg->lock_type && !strcmp(lv->vg->lock_type, "dlm"))
 		lvl->lv->lock_args = lv->lock_args;
 
 	if (!vg_write(lv->vg)) {


