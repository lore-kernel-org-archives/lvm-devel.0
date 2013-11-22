From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Nov 2013 20:09:00 +0000 (UTC)
Subject: master - activate: modify read_only when dev_manager exists
Message-ID: <20131122200900.DFE1A610A4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=069fa6c49d85f677320ccb1965ef2e59b6829303
Commit:        069fa6c49d85f677320ccb1965ef2e59b6829303
Parent:        4a061a35c7523d0a1657a52fc179b520d6bcf4d2
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 22 10:00:00 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 22 20:58:13 2013 +0100

activate: modify read_only when dev_manager exists

Change opts only when dm has been successfully created.
So on the error path we leave structure unmodified.
---
 lib/activate/activate.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 0597409..44dfeb6 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -1097,11 +1097,11 @@ static int _lv_preload(struct logical_volume *lv, struct lv_activate_opts *laopt
 	struct dev_manager *dm;
 	int old_readonly = laopts->read_only;
 
-	laopts->read_only = _passes_readonly_filter(lv->vg->cmd, lv);
-
 	if (!(dm = dev_manager_create(lv->vg->cmd, lv->vg->name, (lv->status & PVMOVE) ? 0 : 1)))
 		goto_out;
 
+	laopts->read_only = _passes_readonly_filter(lv->vg->cmd, lv);
+
 	if (!(r = dev_manager_preload(dm, lv, laopts, flush_required)))
 		stack;
 


