From: David Teigland <teigland@sourceware.org>
Date: Mon, 8 Apr 2019 11:39:51 -0400
Subject: master - pvscan: ignore device with incorrect size
Message-ID: <201904081539.x38FdpLu023050@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=7836e7aa1c17216ed368fda89cfc805a07efda81
Commit:        7836e7aa1c17216ed368fda89cfc805a07efda81
Parent:        6f18186bfd1a67ab0758a987ec53631bf19b0cb7
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Apr 5 16:44:00 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Apr 5 16:44:00 2019 -0500

pvscan: ignore device with incorrect size

If a device looks like a PV, but its size does not
match the PV size in the metadata, then skip it for
purposes of autoactivation.  It's probably not wrong
device for the PV.
---
 tools/pvscan.c |   30 ++++++++++++++++++++++++++++++
 1 files changed, 30 insertions(+), 0 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index 376919b..6a46490 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -624,6 +624,36 @@ static int _online_pvscan_one(struct cmd_context *cmd, struct device *dev,
 		return 1;
 	}
 
+	/*
+	 * Do not consider a device online (for purposes of autoactivation)
+	 * if its size does not match the PV size recorded in the metadata.
+	 * It may mean that it's not the correct dev for the PV, e.g. it
+	 * could be an md component device that's not been filtered.
+	 */
+	if (baton.vg && cmd->check_pv_dev_sizes) {
+		struct pv_list *pvl;
+		uint64_t dev_size = 0;
+		uint64_t meta_pv_size = 0;
+
+		dm_list_iterate_items(pvl, &baton.vg->pvs) {
+			if (pvl->pv->dev != dev)
+				continue;
+
+			if (!dev_get_size(dev, &dev_size))
+				stack;
+			meta_pv_size = pv_size(pvl->pv);
+			break;
+		}
+
+		if (dev_size != meta_pv_size) {
+			log_print("pvscan[%d] PV %s ignore for size %llu not matching device %llu.",
+				  getpid(), dev_name(dev),
+				  (unsigned long long)meta_pv_size, (unsigned long long)dev_size);
+			release_vg(baton.vg);
+			return 1;
+		}
+	}
+
 	ret = _online_pv_found(cmd, dev, dev_args, baton.vg, found_vgnames);
 
 	release_vg(baton.vg);


