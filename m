From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  9 Jan 2015 11:00:14 +0000 (UTC)
Subject: master - metadata: log_error instead of log_warn on failed mda write
Message-ID: <20150109110014.E083C6113C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=db7351d3133e237db01361fed8efd6b0fac85c32
Commit:        db7351d3133e237db01361fed8efd6b0fac85c32
Parent:        08ac12d5e7dd8375fda49dc44c4ee924dcf05b1b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Jan 9 12:00:03 2015 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Jan 9 12:00:03 2015 +0100

metadata: log_error instead of log_warn on failed mda write

---
 lib/metadata/metadata.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 26e43b4..39bd325 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -2795,7 +2795,7 @@ int vg_write(struct volume_group *vg)
 		}
 		if (!mda->ops->vg_write(vg->fid, vg, mda)) {
 			if (vg->cmd->handles_missing_pvs) {
-				log_warn("WARNING: Failed to write an MDA of VG %s.", vg->name);
+				log_error("Failed to write an MDA of VG %s.", vg->name);
 				mda->status |= MDA_FAILED;
 			} else {
 				stack;


