From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 18 Jan 2016 22:09:32 +0000 (UTC)
Subject: master - toollib: add comment about missing device
Message-ID: <20160118220932.6476560BE0@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6b3e402298080a4b3e352ecee3a33cd916d18b6b
Commit:        6b3e402298080a4b3e352ecee3a33cd916d18b6b
Parent:        a3f484f812bfb89063fbc25e378f34cacd50bf7d
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Jan 18 15:40:42 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Jan 18 16:09:22 2016 -0600

toollib: add comment about missing device

Add a comment in _process_pvs_in_vg() to document the
place where there have been problems with processing
PVs twice.

For a while we had a hacky workaround here where we'd
skip processing a PV if its device wasn't found in
all_devices (and !is_missing_pv since we want to
process PVs with missing devices.).  That workaround
was removed in commit 5cd4d46f because it was no
longer needed.

The workaround had originally been needed to prevent
a device from being processed twice when the PV had
no MDAs -- it would be processed once in its real VG
and then the workaround would prevent it from being
processed a second time in the orphan VG.

Wrongly appearing as an orphan likely happened because
lvmcache would consider the no-MDA PV an orphan unless
the real VG holding that PV was also in lvmcache.
This issue is also mentioned in pvchange where holding
the global lock allows VGs to remain in lvmcache so
PVs with 0 mdas are not considered orphans.

The workaround in _process_pvs_in_vg() was originally
intended for reporting commands, not for pvchange.
But, it was accidentally helping pvchange also because
the method described by the pvchange global lock
comment had been subverted by commit 80f4b4b8.
Commit 80f4b4b8 was found to be unnecessary, and was
reverted in commit e710bac0.  This restored the
intended global lock lvmcache effect to pvchange, and
it no longer relied on the workaround in toollib.
---
 tools/toollib.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/tools/toollib.c b/tools/toollib.c
index 97cc1bf..dec9106 100644
--- a/tools/toollib.c
+++ b/tools/toollib.c
@@ -3088,6 +3088,16 @@ static int _process_pvs_in_vg(struct cmd_context *cmd,
 
 			_device_list_remove(all_devices, pv->dev);
 
+			/*
+			 * pv->dev should be found in all_devices unless it's a
+			 * case of a "missing device".  Previously there have
+			 * been cases where we needed to skip processing the PV
+			 * if pv->dev was not found in all_devices to avoid
+			 * processing a PV twice, i.e. when the PV had no MDAs
+			 * it would be seen once in its real VG and again
+			 * wrongly in the orphan VG.  This no longer happens.
+			 */
+
 			if (!skip) {
 				ret = process_single_pv(cmd, vg, pv, handle);
 				if (ret != ECMD_PROCESSED)


