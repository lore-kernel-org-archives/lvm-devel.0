From: David Teigland <teigland@sourceware.org>
Date: Wed,  8 Mar 2023 22:34:43 +0000 (GMT)
Subject: main - vg_read: keep MISSING_PV when device with no mda reappears
Message-ID: <20230308223443.E62993858C83@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=69ea2e3f94815dc94b5fdd8284d30a667690f5df
Commit:        69ea2e3f94815dc94b5fdd8284d30a667690f5df
Parent:        937f1d320980b78b0d70cd778310bf31356ec6da
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Feb 8 13:34:35 2023 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Mar 8 16:31:28 2023 -0600

vg_read: keep MISSING_PV when device with no mda reappears

Remove old code that became incorrect at some point.
It's probably a fragment of an old condition that was left
behind because it wasn't understood.  We don't want to drop
the MISSING_PV flag just because the PV has no mda in use.
The device that was missing may have stale data, so the user
needs to decide if the device should be removed or restored.
---
 lib/metadata/metadata.c | 6 ------
 1 file changed, 6 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 91a23f931..10af75665 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -3571,12 +3571,6 @@ static void _set_pv_device(struct format_instance *fid,
 	if (!pv->dev)
 		pv->status |= MISSING_PV;
 
-	/* is this correct? */
-	if ((pv->status & MISSING_PV) && pv->dev && (pv_mda_used_count(pv) == 0)) {
-		pv->status &= ~MISSING_PV;
-		log_info("Found a previously MISSING PV %s with no MDAs.", pv_dev_name(pv));
-	}
-
 	/* Fix up pv size if missing or impossibly large */
 	if ((!pv->size || pv->size > (1ULL << 62)) && pv->dev) {
 		if (!dev_get_size(pv->dev, &pv->size)) {

