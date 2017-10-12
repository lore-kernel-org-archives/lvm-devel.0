From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Thu, 12 Oct 2017 11:43:48 -0400
Subject: master - lvcreate: allow 100%FREE creation of "--type mirror" to work
Message-ID: <201710121543.v9CFhmYl002259@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=cf13a30eaaf9c9d013f03bfcba1c1bc4973ad5d5
Commit:        cf13a30eaaf9c9d013f03bfcba1c1bc4973ad5d5
Parent:        ae55b1b20a4539be2f9702f5dbf882cf50267a62
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Thu Oct 12 17:43:24 2017 +0200
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Thu Oct 12 17:43:24 2017 +0200

lvcreate: allow 100%FREE creation of "--type mirror" to work

Fixes the following case with 3PVs and 3 legs "mirror" LV:

# lvcreate -l100%FREE --type mirror -m2 vg3
  Insufficient free space for log allocation for logical volume .
  Unable to allocate extents for mirror log.

Related: rhbz1269533
---
 lib/metadata/lv_manip.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 719fcba..15a08aa 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7701,6 +7701,13 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		       lp->pvh, lp->alloc, lp->approx_alloc))
 		return_NULL;
 
+	/* rhbz1269533: allow for 100%FREE allocation to work with "mirror" and a disk log */
+	if (segtype_is_mirror(create_segtype) &&
+	    lp->log_count &&
+	    !vg->free_count &&
+	    lv->le_count > 1)
+		lv_reduce(lv, 1);
+
 	/* Unlock memory if possible */
 	memlock_unlock(vg->cmd);
 


