From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 31 Mar 2014 10:06:40 +0000 (UTC)
Subject: master - lv_rename: resume fail is certainly error
Message-ID: <20140331100640.90AC560AC5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=6570d36ad5dff3f2d9e4822cd8e2c0860d8a720a
Commit:        6570d36ad5dff3f2d9e4822cd8e2c0860d8a720a
Parent:        d3e4934a153a3113038d8458fb62781b234287ea
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 31 11:54:02 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 31 12:03:25 2014 +0200

lv_rename: resume fail is certainly error

Failing resume path means command has failed,
even when commit was ok.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    4 +++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 1760a6b..34d567f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Fail in resume for lvrename will result in failing command.
   Validate length of new LV name in lvrename to not exceed 127 characters.
   Add explict error message when using lvdisplay -c -m.
   Update man pages for pv/vg/lvdisplay.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 7f042e3..bb812e2 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -3382,8 +3382,10 @@ int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 	 * (resume of snapshot resumes origin too)
 	 */
 	dm_list_iterate_back_items(lvlp, &lvs_changed)
-		if (!resume_lv(cmd, lvlp->lv))
+		if (!resume_lv(cmd, lvlp->lv)) {
+			r = 0;
 			stack;
+		}
 out:
 	backup(vg);
 	return r;


