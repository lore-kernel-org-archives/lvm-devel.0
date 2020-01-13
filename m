From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 13 Jan 2020 11:42:02 -0500
Subject: stable-2.02 - raid: disallow reshape of stacked LVs
Message-ID: <79992.120011311415701241@us-mta-124.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=36210c2b491424d7a0ab27d0a65effd6fc6ecc4c
Commit:        36210c2b491424d7a0ab27d0a65effd6fc6ecc4c
Parent:        50c56ade2a7a89f751091669fb8b31854f93eff1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jan 13 17:27:24 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 13 17:41:22 2020 +0100

raid: disallow reshape of stacked LVs

Until we resolve reshape for 'stacked' devices, we need to disable it.
So users can no longer reshape i.e. thin-pool data volumes, causing
ATM bad thin-pool problems.
---
 lib/metadata/raid_manip.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 9030261..548faf1 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -6444,6 +6444,12 @@ int lv_raid_convert(struct logical_volume *lv,
 	uint32_t available_slvs, removed_slvs;
 	takeover_fn_t takeover_fn;
 
+	/* FIXME Can't reshape volume in use - aka not toplevel devices */
+	if (!dm_list_empty(&lv->segs_using_this_lv)) {
+		log_error("Can't reshape stacked volume %s.", display_lvname(lv));
+		return 0;
+	}
+
 	/* FIXME If not active, prompt and activate */
 	/* FIXME Some operations do not require the LV to be active */
 	/* LV must be active to perform raid conversion operations */



