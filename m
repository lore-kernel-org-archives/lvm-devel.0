From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  6 Oct 2021 13:47:47 +0000 (GMT)
Subject: main - metadata: simplify code
Message-ID: <20211006134747.8E0AB385C407@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e30f3c84109b7e131da2497965aee83d73c604e3
Commit:        e30f3c84109b7e131da2497965aee83d73c604e3
Parent:        8e62cbb18e3206ae5860039c3e1a0d3256e93545
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Oct 1 13:43:46 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Oct 6 15:39:58 2021 +0200

metadata: simplify code

---
 lib/metadata/metadata.c | 17 +++++++----------
 1 file changed, 7 insertions(+), 10 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 9a7d23365..b3c8c6ece 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -4977,12 +4977,13 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const
 	int writing = (vg_read_flags & READ_FOR_UPDATE);
 	int activating = (vg_read_flags & READ_FOR_ACTIVATE);
 
+	*error_flags = SUCCESS;
+	if (error_vg)
+		*error_vg = NULL;
+
 	if (is_orphan_vg(vg_name)) {
 		log_very_verbose("Reading orphan VG %s.", vg_name);
 		vg = vg_read_orphans(cmd, vg_name);
-		*error_flags = 0;
-		if (error_vg)
-			*error_vg = NULL;
 		return vg;
 	}
 
@@ -5240,11 +5241,8 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const
 	}
 out:
 	/* We return with the VG lock held when read is successful. */
-	*error_flags = SUCCESS;
-	if (error_vg)
-		*error_vg = NULL;
-	return vg;
 
+	return vg;
 bad:
 	*error_flags = failure;
 
@@ -5273,9 +5271,8 @@ bad:
 		unlock_vg(cmd, vg, vg_name);
 		release_vg(vg);
 	}
-	if (error_vg)
-		*error_vg = NULL;
-	return_NULL;
+
+	return NULL;
 }
 
 /*


