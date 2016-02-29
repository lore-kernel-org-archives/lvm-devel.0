From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 29 Feb 2016 17:20:37 +0000 (UTC)
Subject: master - pvs: display VG name [unknown] for used PV without metadata
Message-ID: <20160229172037.46C4A6029E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=250b915364735a7a9a5e476b542041eb93f5017f
Commit:        250b915364735a7a9a5e476b542041eb93f5017f
Parent:        4013e21ba894d665130bb0d19b7cf31567cbf929
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Feb 26 15:06:20 2016 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Mon Feb 29 11:17:55 2016 -0600

pvs: display VG name [unknown] for used PV without metadata

Rather than displaying a blank field for VG name.
---
 lib/report/report.c |   25 ++++++++++++++++++++-----
 1 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index bd7c163..39dbb67 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3376,6 +3376,16 @@ static struct volume_group _dummy_vg = {
 	.tags = DM_LIST_HEAD_INIT(_dummy_vg.tags),
 };
 
+static struct volume_group _unknown_vg = {
+	.fid = &_dummy_fid,
+	.name = "[unknown]",
+	.system_id = (char *) "",
+	.lvm1_system_id = (char *) "",
+	.pvs = DM_LIST_HEAD_INIT(_unknown_vg.pvs),
+	.lvs = DM_LIST_HEAD_INIT(_unknown_vg.lvs),
+	.tags = DM_LIST_HEAD_INIT(_unknown_vg.tags),
+};
+
 static void *_obj_get_vg(void *obj)
 {
 	struct volume_group *vg = ((struct lvm_report_object *)obj)->vg;
@@ -3582,12 +3592,17 @@ int report_object(void *handle, int selection_only, const struct volume_group *v
 	}
 
 	/* Never report orphan VGs. */
-	if (vg && is_orphan_vg(vg->name))
-		obj.vg = NULL;
+	if (vg && is_orphan_vg(vg->name)) {
+		obj.vg = &_dummy_vg;
+		if (pv)
+			_dummy_fid.fmt = pv->fmt;
+	}
 
-	/* The two format fields might as well match. */
-	if (!obj.vg && pv)
-		_dummy_fid.fmt = pv->fmt;
+	if (vg && is_orphan_vg(vg->name) && is_used_pv(pv)) {
+		obj.vg = &_unknown_vg;
+		if (pv)
+			_dummy_fid.fmt = pv->fmt;
+	}
 
 	return sh ? dm_report_object_is_selected(sh->selection_rh, &obj, 0, &sh->selected)
 		  : dm_report_object(handle, &obj);


