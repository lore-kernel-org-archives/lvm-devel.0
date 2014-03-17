From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Mon, 17 Mar 2014 13:33:14 +0000 (UTC)
Subject: master - lvconvert: validate min chunk size for snapshot
Message-ID: <20140317133314.0B88360EAF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=d425e788e9ebaa2eef1fd747aec4dad03897114e
Commit:        d425e788e9ebaa2eef1fd747aec4dad03897114e
Parent:        3a82490ee1cf7aec5b2d6648f9bc74d9791eca8e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Mar 17 13:06:00 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Mar 17 14:31:43 2014 +0100

lvconvert: validate min chunk size for snapshot

Do not allow conversion of too small LV into a COW snapshot device.

Without this patch snapshot target is generating these kernel
messages before creation fails:

attempt to access beyond end of device
dm-9: rw=16, want=8, limit=2
attempt to access beyond end of device
...
device-mapper: table: 253:11: snapshot: Failed to read snapshot metadata
device-mapper: ioctl: error adding target to table
device-mapper: reload ioctl on  failed: Input/output error
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    3 +++
 2 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index c3c8aff..06b8033 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.106 - 
 ====================================
+  Validate minimal chunk size for snapshot COW volume in lvconvert.
   Disallow lvconvert of origin to snapshot COW volume.
   Make report settings profilable.
   Add existing report settings to lvm.conf.
diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 1b9d9f7..7f27dd4 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2055,6 +2055,9 @@ static int _lvconvert_snapshot(struct cmd_context *cmd,
 		return 0;
 	}
 
+	if (!cow_has_min_chunks(lv->vg, lv->le_count, lp->chunk_size))
+		return_0;
+
 	if (org->status & (LOCKED|PVMOVE|MIRRORED) || lv_is_cow(org)) {
 		log_error("Unable to convert an LV into a snapshot of a %s LV.",
 			  org->status & LOCKED ? "locked" :


