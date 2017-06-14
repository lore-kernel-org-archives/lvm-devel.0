From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 14 Jun 2017 09:02:03 -0400
Subject: master - raid: change reshape segtype flags
Message-ID: <201706141302.v5ED23W5005819@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=14d563accc7692dfd827a4db91912c9ab498ca1f
Commit:        14d563accc7692dfd827a4db91912c9ab498ca1f
Parent:        08079ec42062944eadcd4e5625edafe45b36c55c
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Jun 14 15:01:19 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Jun 14 15:01:19 2017 +0200

raid: change reshape segtype flags

Commit 1c916ec5ffd37cfb7be2101b93a2dc91aa2ef7f0
missed new reshape flags.
---
 lib/format_text/flags.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/format_text/flags.c b/lib/format_text/flags.c
index a9548e0..88fb091 100644
--- a/lib/format_text/flags.c
+++ b/lib/format_text/flags.c
@@ -63,9 +63,9 @@ static const struct flag _lv_flags[] = {
 	{LV_NOTSYNCED, "NOTSYNCED", STATUS_FLAG},
 	{LV_REBUILD, "REBUILD", STATUS_FLAG},
 	{LV_RESHAPE, "RESHAPE", SEGTYPE_FLAG},
-	{LV_RESHAPE_DELTA_DISKS_PLUS, "RESHAPE_DELTA_DISKS_PLUS", STATUS_FLAG},
-	{LV_RESHAPE_DELTA_DISKS_MINUS, "RESHAPE_DELTA_DISKS_MINUS", STATUS_FLAG},
-	{LV_REMOVE_AFTER_RESHAPE, "REMOVE_AFTER_RESHAPE", STATUS_FLAG},
+	{LV_RESHAPE_DELTA_DISKS_PLUS, "RESHAPE_DELTA_DISKS_PLUS", SEGTYPE_FLAG},
+	{LV_RESHAPE_DELTA_DISKS_MINUS, "RESHAPE_DELTA_DISKS_MINUS", SEGTYPE_FLAG},
+	{LV_REMOVE_AFTER_RESHAPE, "REMOVE_AFTER_RESHAPE", SEGTYPE_FLAG},
 	{LV_WRITEMOSTLY, "WRITEMOSTLY", STATUS_FLAG},
 	{LV_ACTIVATION_SKIP, "ACTIVATION_SKIP", COMPATIBLE_FLAG},
 	{LV_ERROR_WHEN_FULL, "ERROR_WHEN_FULL", COMPATIBLE_FLAG},


