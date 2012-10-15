From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Mon, 15 Oct 2012 20:11:13 +0000 (UTC)
Subject: master - Clean-up: Adjust message to be clearer on action taken and why
Message-ID: <20121015201113.32A63A0C45@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7519d881ef07c4a515716099a4bf9566b7f71b1a
Commit:        7519d881ef07c4a515716099a4bf9566b7f71b1a
Parent:        ea6a8078b41df75344aecff4c54aab9c78b67193
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Mon Oct 15 15:09:05 2012 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Mon Oct 15 15:09:05 2012 -0500

Clean-up:  Adjust message to be clearer on action taken and why

A message is printed when the region_size of a RAID LV is adjusted
to allow for large (> ~1TB) LVs.  The message wasn't very clear.
Hopefully, this is better.
---
 lib/metadata/lv_manip.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d469fe8..5f006ab 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -2668,8 +2668,9 @@ static int _lv_extend_layered_lv(struct alloc_handle *ah,
 	 */
 	while (seg_is_raid(seg) && (seg->region_size < (lv->size / (1 << 21)))) {
 		seg->region_size *= 2;
-		log_very_verbose("Forced to adjust RAID region_size to %uS",
-				 seg->region_size);
+		log_very_verbose("Adjusting RAID region_size from %uS to %uS"
+				 " to support large LV size",
+				 seg->region_size/2, seg->region_size);
 	}
 
 	return 1;


