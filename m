From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 17 Dec 2018 05:07:53 -0500
Subject: master - lvconvert: ensure proper init of pv_list
Message-ID: <201812171007.wBHA7rx8024710@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f514e379786689a47518bf67d71a388977cc7369
Commit:        f514e379786689a47518bf67d71a388977cc7369
Parent:        2e01af0f78fb63c084998f728668553d8cce2b64
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 14 21:53:34 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 14 22:27:33 2018 +0100

lvconvert: ensure proper init of pv_list

---
 tools/lvconvert.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 8329bc6..c260ee0 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -484,7 +484,7 @@ static struct dm_list *_failed_pv_list(struct volume_group *vg)
 		if (pvl->pv->pe_alloc_count == 0)
 			continue;
 
-		if (!(new_pvl = dm_pool_alloc(vg->vgmem, sizeof(*new_pvl)))) {
+		if (!(new_pvl = dm_pool_zalloc(vg->vgmem, sizeof(*new_pvl)))) {
 			log_error("Allocation of failed_pvs list entry failed.");
 			return NULL;
 		}


