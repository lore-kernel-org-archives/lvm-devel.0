From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 17 Jul 2013 09:32:27 +0000 (UTC)
Subject: master - profile: move profile assignment to common lv_create_empty fn
Message-ID: <20130717093227.5818F611C5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=73e7f6c45ffecc78b1ea4165596355479fb59fe2
Commit:        73e7f6c45ffecc78b1ea4165596355479fb59fe2
Parent:        b73fbf8f4a225262b2c1d42978aea015af941a50
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jul 17 11:31:54 2013 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jul 17 11:31:54 2013 +0200

profile: move profile assignment to common lv_create_empty fn

---
 lib/metadata/lv_manip.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 5ec2bd0..cb6a6c2 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4183,6 +4183,9 @@ struct logical_volume *lv_create_empty(const char *name,
  
 	if (fi->fmt->ops->lv_setup && !fi->fmt->ops->lv_setup(fi, lv))
 		goto_bad;
+
+	if (vg->fid->fmt->features & FMT_CONFIG_PROFILE)
+		lv->profile = vg->cmd->profile_params->global_profile;
  
 	return lv;
 bad:
@@ -5595,9 +5598,6 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg, struct l
 				   status, lp->alloc, vg)))
 		return_NULL;
 
-	if (vg->fid->fmt->features & FMT_CONFIG_PROFILE)
-		lv->profile = vg->cmd->profile_params->global_profile;
-
 	if (lp->read_ahead != lv->read_ahead) {
 		log_verbose("Setting read ahead sectors");
 		lv->read_ahead = lp->read_ahead;


