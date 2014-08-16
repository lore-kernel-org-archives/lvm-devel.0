From: Jonathan Brassow <jbrassow@fedoraproject.org>
Date: Sat, 16 Aug 2014 02:15:48 +0000 (UTC)
Subject: master - RAID: Fail RAID4/5/6 creation if PE size is less than STRIPE_SIZE_MIN
Message-ID: <20140816021548.2EACA60355@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=4d45302e25f5fe1251bdd8f2c49c4a75a4a31d2e
Commit:        4d45302e25f5fe1251bdd8f2c49c4a75a4a31d2e
Parent:        42e07d2bceaad21f197de5dde9ead69742425159
Author:        Jonathan Brassow <jbrassow@redhat.com>
AuthorDate:    Fri Aug 15 21:15:34 2014 -0500
Committer:     Jonathan Brassow <jbrassow@redhat.com>
CommitterDate: Fri Aug 15 21:15:34 2014 -0500

RAID: Fail RAID4/5/6 creation if PE size is less than STRIPE_SIZE_MIN

The maximum stripe size is equal to the volume group PE size.  If that
size falls below the STRIPE_SIZE_MIN, the creation of RAID 4/5/6 volumes
becomes impossible.  (The kernel will fail to load a RAID 4/5/6 mapping
table with a stripe size less than STRIPE_SIZE_MIN.)  So, we report an
error if it is attempted.

This is very rare because reducing the PE size down that far limits the
size of the PV below that of modern devices.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |   15 +++++++++++++++
 2 files changed, 16 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index a5daf80..2e2a064 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.110 -
 ==================================
+  Cleanly error when creating RAID with stripe size < PAGE_SIZE.
   Print name of LV which on activation triggers delayed snapshot merge.
   Add lv_layout and lv_type LV reporting fields.
   Properly display lvs lv_attr volume type and target type bit for cache origin.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d86bdc1..b2e927d 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6364,6 +6364,21 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 	}
 
 	if (lp->stripe_size > vg->extent_size) {
+		if (segtype_is_raid(lp->segtype) &&
+		    (vg->extent_size < STRIPE_SIZE_MIN)) {
+			/*
+			 * FIXME: RAID will simply fail to load the table if
+			 *        this is the case, but we should probably
+			 *        honor the stripe minimum for regular stripe
+			 *        volumes as well.  Avoiding doing that now
+			 *        only to minimize the change.
+			 */
+			log_error("The extent size in volume group %s is too"
+				  " small to support striped RAID volumes.",
+				  vg->name);
+			return NULL;
+		}
+
 		log_print_unless_silent("Reducing requested stripe size %s to maximum, "
 					"physical extent size %s.",
 					display_size(cmd, (uint64_t) lp->stripe_size),


