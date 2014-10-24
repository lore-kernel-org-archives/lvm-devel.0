From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 24 Oct 2014 14:40:43 +0000 (UTC)
Subject: master - cleanup: don't backup twice
Message-ID: <20141024144043.1B27E60CE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=f2ea8904239752df231023a4a3aad704ed8edc73
Commit:        f2ea8904239752df231023a4a3aad704ed8edc73
Parent:        a4788b4994f4cbd5bccd411683704b2badf026d7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 20 21:49:07 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Oct 24 16:39:31 2014 +0200

cleanup: don't backup twice

---
 lib/metadata/lv_manip.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index df696e9..54fc6a8 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -7052,8 +7052,9 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				stack;
 				goto revert_new_lv;
 			}
-
-			backup(vg);
+			/* When change is activating, don't duplicate backup call */
+			if (!is_change_activating(lp->activate))
+				backup(vg);
 		}
 		if (is_change_activating(lp->activate)) {
 			/* Send message so that table preload knows new thin */


