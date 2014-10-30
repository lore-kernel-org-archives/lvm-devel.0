From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 30 Oct 2014 23:00:45 +0000 (UTC)
Subject: master - pv_manip: check for pe_ranges
Message-ID: <20141030230045.3857260DD0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=375d7f1c2d4ebe86cb54fce454f503758e02bb7a
Commit:        375d7f1c2d4ebe86cb54fce454f503758e02bb7a
Parent:        464f3b8abd03633ff5dd2c5fe5585d921af8931f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Oct 28 11:02:58 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Oct 30 23:58:49 2014 +0100

pv_manip: check for pe_ranges

---
 lib/metadata/pv_manip.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/pv_manip.c b/lib/metadata/pv_manip.c
index 9a0f287..00a7fd5 100644
--- a/lib/metadata/pv_manip.c
+++ b/lib/metadata/pv_manip.c
@@ -374,6 +374,10 @@ uint32_t pv_list_extents_free(const struct dm_list *pvh)
 	struct pv_segment *pvseg;
 
 	dm_list_iterate_items(pvl, pvh) {
+		if (!pvl->pe_ranges) {
+			log_warn(INTERNAL_ERROR "WARNING: PV %s is without initialized PE ranges.", dev_name(pvl->pv->dev));
+			continue;
+		}
 		dm_list_iterate_items(per, pvl->pe_ranges) {
 			dm_list_iterate_items(pvseg, &pvl->pv->segments) {
 				if (!pvseg_is_allocated(pvseg))


