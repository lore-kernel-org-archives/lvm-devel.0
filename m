From: Alasdair Kergon <agk@fedoraproject.org>
Date: Thu, 16 Jan 2014 23:05:09 +0000 (UTC)
Subject: master - pvresize: Avoid archiving orphan VG metadata.
Message-ID: <20140116230509.3667660DF5@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ebac2ed5be9ba2bd4c606209f1a9396e32dafe88
Commit:        ebac2ed5be9ba2bd4c606209f1a9396e32dafe88
Parent:        b662f3c8dd52f489a8f5b5eeb69bc37ea40ff768
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Thu Jan 16 23:02:59 2014 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Thu Jan 16 23:02:59 2014 +0000

pvresize: Avoid archiving orphan VG metadata.

Block creations of archive and backup files for internal orphan VGs.

Bug introduced by 603b45e0ed1032875f587eda3391c47b6652303c ("pvresize: Do
not use pv_read (get the PV from orphan VG).")
---
 lib/format_text/archiver.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/lib/format_text/archiver.c b/lib/format_text/archiver.c
index c1fe3f5..31d17ef 100644
--- a/lib/format_text/archiver.c
+++ b/lib/format_text/archiver.c
@@ -111,6 +111,10 @@ static int __archive(struct volume_group *vg)
 
 int archive(struct volume_group *vg)
 {
+	/* Don't archive orphan VGs. */
+	if (is_orphan_vg(vg->name))
+		return 1;
+
 	if (vg_is_archived(vg))
 		return 1; /* VG has been already archived */
 
@@ -251,6 +255,10 @@ int backup_locally(struct volume_group *vg)
 
 int backup(struct volume_group *vg)
 {
+	/* Don't back up orphan VGs. */
+	if (is_orphan_vg(vg->name))
+		return 1;
+
 	if (vg_is_clustered(vg))
 		if (!remote_backup_metadata(vg))
 			stack;


