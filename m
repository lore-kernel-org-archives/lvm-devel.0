From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Apr 2016 12:16:16 +0000 (UTC)
Subject: master - coverity: is_used_pv needs valid pv pointer
Message-ID: <20160422121616.BE9A361BBE@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d564d9f39c73bdbb32413256586991993ad869ef
Commit:        d564d9f39c73bdbb32413256586991993ad869ef
Parent:        2dc6b9785658d7bf0cf97170e8e1467b522bded6
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 21 20:23:13 2016 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 22 14:15:36 2016 +0200

coverity: is_used_pv needs valid pv pointer

---
 lib/report/report.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 08a6097..abf6a9e 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -3827,10 +3827,9 @@ int report_object(void *handle, int selection_only, const struct volume_group *v
 			_dummy_fid.fmt = pv->fmt;
 	}
 
-	if (vg && is_orphan_vg(vg->name) && is_used_pv(pv)) {
+	if (vg && is_orphan_vg(vg->name) && pv && is_used_pv(pv)) {
 		obj.vg = &_unknown_vg;
-		if (pv)
-			_dummy_fid.fmt = pv->fmt;
+		_dummy_fid.fmt = pv->fmt;
 	}
 
 	return sh ? dm_report_object_is_selected(sh->selection_rh, &obj, 0, &sh->selected)


