From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 12 Sep 2014 12:45:03 +0000 (UTC)
Subject: master - debug: add missing stack trace on error path
Message-ID: <20140912124503.E316960DE9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ad376e9e00eaa453e7d8ba1ffdc763345ec49d0e
Commit:        ad376e9e00eaa453e7d8ba1ffdc763345ec49d0e
Parent:        c10c16cc3531cf613152675b732a50b1339e62c9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Sep 11 20:11:44 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 12 13:51:29 2014 +0200

debug: add missing stack trace on error path

---
 lib/metadata/raid_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 6edd56d..d0740e8 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -1238,7 +1238,7 @@ int lv_raid_split_and_track(struct logical_volume *lv,
 
 	/* Activate the split (and tracking) LV */
 	if (!_activate_sublv_preserving_excl(lv, seg_lv(seg, s)))
-		return 0;
+		return_0;
 
 	log_print_unless_silent("Use 'lvconvert --merge %s/%s' to merge back into %s",
 				lv->vg->name, seg_lv(seg, s)->name, lv->name);
@@ -1907,7 +1907,7 @@ int partial_raid_lv_supports_degraded_activation(struct logical_volume *lv)
 	int not_capable = 0;
 
 	if (!_lv_may_be_activated_in_degraded_mode(lv, &not_capable) || not_capable)
-		return 0;
+		return_0;
 
 	if (!for_each_sub_lv(lv, _lv_may_be_activated_in_degraded_mode, &not_capable)) {
 		log_error(INTERNAL_ERROR "for_each_sub_lv failure.");


