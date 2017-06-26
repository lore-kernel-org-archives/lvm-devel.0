From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 26 Jun 2017 18:29:47 -0400
Subject: master - debug: fail in backup is not traced nor error
Message-ID: <201706262229.v5QMTlNu010231@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=d444accdbfdda0712d4a83ac178378580d3f7714
Commit:        d444accdbfdda0712d4a83ac178378580d3f7714
Parent:        c3e0ef1a5eef973bb79c3f94653077cc87b250c0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 26 23:27:10 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 27 00:27:36 2017 +0200

debug: fail in backup is not traced nor error

---
 lib/metadata/raid_manip.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 774924a..110a7d3 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -2147,8 +2147,8 @@ static int _vg_write_lv_suspend_commit_backup(struct volume_group *vg,
 	} else if (!(r = vg_commit(vg)))
 		stack; /* !vg_commit() has implicit vg_revert() */
 
-	if (r && do_backup && !backup(vg))
-		log_error("Backup of VG %s failed; continuing.", vg->name);
+	if (r && do_backup)
+		backup(vg);
 
 	return r;
 }


