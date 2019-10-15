From: David Teigland <teigland@sourceware.org>
Date: Tue, 15 Oct 2019 15:36:30 -0400
Subject: master - allow activating known LVs when other LVs have unknown segtypes
Message-ID: <201910151936.x9FJaUOq008336@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0443d00ff1efdb5af05def774a4961563377dbd0
Commit:        0443d00ff1efdb5af05def774a4961563377dbd0
Parent:        91ee025d5bf5188c3519a674eaa28769a8922a18
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Mon Oct 14 15:51:35 2019 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Oct 15 14:34:53 2019 -0500

allow activating known LVs when other LVs have unknown segtypes

When a VG contains some LVs with unknown segtypes, the user
should still be allowed to activate other LVs in the VG that
are understood.

$ lvs foo
  WARNING: Unrecognised flag CACHE_USES_CACHEVOL in segment type cache+CACHE_USES_CACHEVOL.
  WARNING: Unrecognised segment type cache+CACHE_USES_CACHEVOL
  LV    VG  Attr       LSize
  lvol0 foo -wi-------  4.00m
  other foo vwi---u--- 48.00m

$ lvcreate -l1 foo
  WARNING: Unrecognised flag CACHE_USES_CACHEVOL in segment type cache+CACHE_USES_CACHEVOL.
  WARNING: Unrecognised segment type cache+CACHE_USES_CACHEVOL
  Cannot change VG foo with unknown segments in it!
  Cannot process volume group foo

$ lvchange -ay foo/lvol0
  WARNING: Unrecognised flag CACHE_USES_CACHEVOL in segment type cache+CACHE_USES_CACHEVOL.
  WARNING: Unrecognised segment type cache+CACHE_USES_CACHEVOL

$ lvchange -ay foo/other
  WARNING: Unrecognised flag CACHE_USES_CACHEVOL in segment type cache+CACHE_USES_CACHEVOL.
  WARNING: Unrecognised segment type cache+CACHE_USES_CACHEVOL
  Refusing activation of LV foo/other containing an unrecognised segment.

$ lvs foo
  WARNING: Unrecognised flag CACHE_USES_CACHEVOL in segment type cache+CACHE_USES_CACHEVOL.
  WARNING: Unrecognised segment type cache+CACHE_USES_CACHEVOL
  LV    VG  Attr       LSize
  lvol0 foo -wi-a-----  4.00m
  other foo vwi---u--- 48.00m
---
 lib/metadata/metadata.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index b09f4b3..3174ae0 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -5065,12 +5065,12 @@ struct volume_group *vg_read(struct cmd_context *cmd, const char *vg_name, const
 			failure |= FAILED_NOT_ENABLED;
 			goto_bad;
 		}
+	}
 
-		if (!cmd->handles_unknown_segments && vg_has_unknown_segments(vg)) {
-			log_error("Cannot change VG %s with unknown segments in it!", vg->name);
-			failure |= FAILED_NOT_ENABLED; /* FIXME new failure code here? */
-			goto_bad;
-		}
+	if (writing && !cmd->handles_unknown_segments && vg_has_unknown_segments(vg)) {
+		log_error("Cannot change VG %s with unknown segments in it!", vg->name);
+		failure |= FAILED_NOT_ENABLED; /* FIXME new failure code here? */
+		goto_bad;
 	}
 
 	/*


