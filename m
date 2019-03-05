From: David Teigland <teigland@sourceware.org>
Date: Tue, 5 Mar 2019 16:20:56 -0500
Subject: master - pvscan: ignore online for shared and foreign PVs
Message-ID: <201903052120.x25LKupl022271@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4e20ebd6a1b993b1f04aa13f55b9c5d8ca2ff287
Commit:        4e20ebd6a1b993b1f04aa13f55b9c5d8ca2ff287
Parent:        a0c848d4e4a9b53fa1f9cc7a8330fea6b23c07a8
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Mar 5 15:19:05 2019 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Mar 5 15:19:05 2019 -0600

pvscan: ignore online for shared and foreign PVs

Activation would not be allowed anyway, but we can
check for these cases early and avoid wasted time in
pvscan managing online files an attempting activation.
---
 lib/metadata/metadata-exported.h |    2 ++
 lib/metadata/metadata.c          |    5 +++++
 tools/pvscan.c                   |   12 ++++++++++++
 3 files changed, 19 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index f451140..df217db 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -1377,4 +1377,6 @@ int vg_strip_outdated_historical_lvs(struct volume_group *vg);
 
 int lv_on_pmem(struct logical_volume *lv);
 
+int vg_is_foreign(struct volume_group *vg);
+
 #endif
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 9efc355..c50e633 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -5668,3 +5668,8 @@ int lv_on_pmem(struct logical_volume *lv)
 	return 0;
 }
 
+int vg_is_foreign(struct volume_group *vg)
+{
+	return _is_foreign_vg(vg);
+}
+
diff --git a/tools/pvscan.c b/tools/pvscan.c
index c484531..30f6fe8 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -696,6 +696,18 @@ static int _online_pvscan_one(struct cmd_context *cmd, struct device *dev,
 		fmt->ops->destroy_instance(baton.fid);
 	}
 
+	if (baton.vg && vg_is_shared(baton.vg)) {
+		log_print("pvscan[%d] PV %s ignore shared VG.", getpid(), dev_name(dev));
+		release_vg(baton.vg);
+		return 1;
+	}
+
+	if (baton.vg && vg_is_foreign(baton.vg)) {
+		log_print("pvscan[%d] PV %s ignore foreign VG.", getpid(), dev_name(dev));
+		release_vg(baton.vg);
+		return 1;
+	}
+
 	ret = _online_pv_found(cmd, dev, dev_args, baton.vg, found_vgnames);
 
 	release_vg(baton.vg);


