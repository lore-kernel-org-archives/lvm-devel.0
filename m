From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  4 Mar 2016 10:46:37 +0000 (UTC)
Subject: master - cleanup: comment in the code for renaming historical LVs
Message-ID: <20160304104637.4976060A52@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=fa06c2263b24561c25c04aefd93204f7cfc39543
Commit:        fa06c2263b24561c25c04aefd93204f7cfc39543
Parent:        27245d97e57bb42b83aa240979aa6febf9096264
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Mar 4 11:46:29 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Mar 4 11:46:29 2016 +0100

cleanup: comment in the code for renaming historical LVs

---
 lib/metadata/lv_manip.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 9b51b6d..91a010c 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4225,7 +4225,10 @@ int lv_rename_update(struct cmd_context *cmd, struct logical_volume *lv,
 		return_0;
 
 	if (old_lv_is_historical) {
-		/* historical LVs don't have sub LVs */
+		/*
+		 * Historical LVs have neither sub LVs nor any
+		 * devices to reload, so just update metadata.
+		 */
 		lv->this_glv->historical->name = lv->name = new_name;
 		if (update_mda &&
 		    (!vg_write(vg) || !vg_commit(vg)))


