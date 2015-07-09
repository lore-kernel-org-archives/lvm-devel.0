From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu,  9 Jul 2015 11:13:04 +0000 (UTC)
Subject: master - coverity: missing return value for dm_split_lvm_name pass proper DM name instead of NULL value
Message-ID: <20150709111304.D126760AC5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a9a7c297aebe82ddc9092b7b19cc9cfcc27e117e
Commit:        a9a7c297aebe82ddc9092b7b19cc9cfcc27e117e
Parent:        023cf21848bdf75bade560f6f43b2dea62a54f80
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 9 13:11:57 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jul 9 13:11:57 2015 +0200

coverity: missing return value for dm_split_lvm_name pass proper DM name instead of NULL value

---
 daemons/lvmlockd/lvmlockd-core.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/daemons/lvmlockd/lvmlockd-core.c b/daemons/lvmlockd/lvmlockd-core.c
index ff5510c..eee1da1 100644
--- a/daemons/lvmlockd/lvmlockd-core.c
+++ b/daemons/lvmlockd/lvmlockd-core.c
@@ -4726,7 +4726,10 @@ static int remove_inactive_lvs(struct list_head *vg_lockd)
 		strncpy(namebuf, names->name, MAX_NAME);
 		vgname = namebuf;
 
-		dm_split_lvm_name(NULL, NULL, &vgname, &lvname, &layer);
+		if (!dm_split_lvm_name(NULL, namebuf, &vgname, &lvname, &layer)) {
+			log_error("failed to split dm name %s", namebuf);
+			goto next_dmname;
+		}
 
 		log_debug("adopt remove_inactive dm name %s dm uuid %s vgname %s lvname %s",
 			  names->name, dm_uuid, vgname, lvname);


