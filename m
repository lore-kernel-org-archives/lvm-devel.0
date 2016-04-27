From: David Teigland <teigland@fedoraproject.org>
Date: Wed, 27 Apr 2016 17:23:06 +0000 (UTC)
Subject: master - metadata: fix segfault when filters reject devices
Message-ID: <20160427172306.75B3A60EE4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3c53acb378478f23acf624be8836c0cb24c2724e
Commit:        3c53acb378478f23acf624be8836c0cb24c2724e
Parent:        49f32e4859017104555ba0297fa0384d4aa3d5f2
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Wed Apr 27 12:13:26 2016 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Wed Apr 27 12:13:26 2016 -0500

metadata: fix segfault when filters reject devices

Checking for devices uses is_missing_pv() to check
if there is a device for the PV.  is_missing_pv()
is based on the MISSING_PV flag, which does not
always correspond to !pv->dev.  When using lvmetad,
a command like:

pvs --config 'devices/filter=["a|/dev/sdb|", "r|.*|"]'

will cause a number of PVs to have NULL pv->dev, but
not the MISSING_PV flag.  So, NULL pv->dev needs to
also be checked.
---
 lib/metadata/metadata.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 6d101e0..c8237d5 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4682,6 +4682,15 @@ static int _check_devs_used_correspond_with_vg(struct volume_group *vg)
 
 	/* Mark all PVs in VG as used. */
 	dm_list_iterate_items(pvl, &vg->pvs) {
+		/*
+		 * FIXME: It's not clear if the meaning
+		 * of "missing" should always include the
+		 * !pv->dev case, or if "missing" is the
+		 * more narrow case where VG metadata has
+		 * been written with the MISSING flag.
+		 */
+		if (!pvl->pv->dev)
+			continue;
 		if (is_missing_pv(pvl->pv))
 			continue;
 		pvl->pv->dev->flags |= DEV_ASSUMED_FOR_LV;


