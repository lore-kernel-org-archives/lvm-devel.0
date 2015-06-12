From: Alasdair Kergon <agk@fedoraproject.org>
Date: Fri, 12 Jun 2015 15:10:16 +0000 (UTC)
Subject: master - metadata: Explain the pvs_outdated field in struct volume_group.
Message-ID: <20150612151016.426FB60AAD@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=756d027da5cd0e10b10181515a75ecf8d275a5b3
Commit:        756d027da5cd0e10b10181515a75ecf8d275a5b3
Parent:        fd29c7f3a171174dcd47eb8b23ff42a145cdacc6
Author:        Petr Rockai <prockai@redhat.com>
AuthorDate:    Wed Jun 10 16:17:45 2015 +0200
Committer:     Petr Rockai <prockai@redhat.com>
CommitterDate: Wed Jun 10 16:17:45 2015 +0200

metadata: Explain the pvs_outdated field in struct volume_group.

---
 lib/metadata/vg.h |   13 ++++++++++++-
 1 files changed, 12 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/vg.h b/lib/metadata/vg.h
index bb21f34..2da5651 100644
--- a/lib/metadata/vg.h
+++ b/lib/metadata/vg.h
@@ -92,7 +92,18 @@ struct volume_group {
 
 	/*
 	 * List of physical volumes that carry outdated metadata that belongs
-	 * to this VG. Currently only populated when lvmetad is in use.
+	 * to this VG. Currently only populated when lvmetad is in use. The PVs
+	 * on this list could still belong to the VG (but their MDA carries an
+	 * out-of-date copy of the VG metadata) or they could no longer belong
+	 * to the VG. With lvmetad, this list is populated with all PVs that
+	 * have a VGID matching ours, but seqno that is smaller than the
+	 * current seqno for the VG. The MDAs on still-in-VG PVs are updated as
+	 * part of the normal vg_write/vg_commit process. The MDAs on PVs that
+	 * no longer belong to the VG are wiped during vg_read.
+	 *
+	 * However, even though still-in-VG PVs *may* be on the list, this is
+	 * not guaranteed. The in-lvmetad list is cleared whenever out-of-VG
+	 * outdated PVs are wiped during vg_read.
 	 */
 
 	struct dm_list pvs_outdated;


