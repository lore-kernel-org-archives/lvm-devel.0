From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 10 Mar 2016 12:12:55 +0000 (UTC)
Subject: master - metadata: do not issue warning message about PV dev size being 0 when the device has gone just after VG read
Message-ID: <20160310121255.0EB3760EB3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9918d95490d46dee12768494dcc8afe784dd19c0
Commit:        9918d95490d46dee12768494dcc8afe784dd19c0
Parent:        8f01ee3035cf5ede72a8653fd1dca2987db29475
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Mar 10 13:02:38 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Mar 10 13:11:15 2016 +0100

metadata: do not issue warning message about PV dev size being 0 when the device has gone just after VG read

There's a window between doing VG read and checking PV device size
against real device size. If the device is removed in this window,
the dev cache still holds struct device and pv->dev still references
that and that PV is not marked as missing. However, if we're trying
to get size for such device, the open fails because that device
doesn't exists anymore.

We called existing pv_dev_size in _check_pv_dev_sizes fn. But
pv_dev_size assigned a size of 0 if the dev_get_size it called failed
(because the device is gone).

So call the dev_get_size directly and check for the return code
in _check_pv_dev_sizes and go further only if we really know the
device size. This is to avoid confusing warning messages like:

  Device /dev/sdd1 has size of 0 sectors which is smaller than corresponding PV size of 31455207 sectors. Was device resized?
  One or more devices used as PVs in VG helter_skelter have changed sizes.
---
 lib/metadata/metadata.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 1330cc0..d04adb6 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -680,8 +680,14 @@ static int _check_pv_dev_sizes(struct volume_group *vg)
 	dm_list_iterate_items(pvl, &vg->pvs) {
 		if (is_missing_pv(pvl->pv))
 			continue;
-
-		dev_size = pv_dev_size(pvl->pv);
+		/*
+		 * Don't compare the sizes if we're not able
+		 * to determine the real dev_size. This may
+		 * happen if the device has gone since we did
+		 * VG read.
+		 */
+		if (!dev_get_size(pvl->pv->dev, &dev_size))
+			continue;
 		size = pv_size(pvl->pv);
 
 		if (dev_size < size) {


