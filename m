From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon,  6 Oct 2014 13:33:02 +0000 (UTC)
Subject: master - lv_manip: fix out of order backup
Message-ID: <20141006133302.07043609E5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0662391ff60c5fbdf4b941bad92de31558ecd89b
Commit:        0662391ff60c5fbdf4b941bad92de31558ecd89b
Parent:        a0cfc5eee2763b7e68c028b517db1825c1f3cce7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 3 18:39:54 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 6 15:18:05 2014 +0200

lv_manip: fix out of order backup

We had only 2 remaining places that were leaving unbackuped metadata.
---
 lib/metadata/lv_manip.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 6136b43..25342d6 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7031,6 +7031,8 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				stack;
 				goto revert_new_lv;
 			}
+
+			backup(vg);
 		}
 		if (is_change_activating(lp->activate)) {
 			/* Send message so that table preload knows new thin */
@@ -7038,6 +7040,9 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				stack;
 				goto revert_new_lv;
 			}
+
+			backup(vg);
+
 			if (!lv_active_change(cmd, lv, lp->activate)) {
 				log_error("Failed to activate thin %s.", lv->name);
 				goto deactivate_and_revert_new_lv;
@@ -7125,8 +7130,6 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 		if (!lv_update_and_reload(org))
 			return_0;
 	}
-	/* FIXME out of sequence */
-	backup(vg);
 
 out:
 	return lv;


