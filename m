From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Sun, 18 Dec 2016 18:52:02 +0000 (UTC)
Subject: master - lvs: show status for layer
Message-ID: <20161218185202.6804760E25@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=c71fefad8d5e1d9a075553ab69791ddbf6bcb153
Commit:        c71fefad8d5e1d9a075553ab69791ddbf6bcb153
Parent:        bdfc96cb089031c6d95dccb0ff66616efdb16783
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Sat Dec 17 21:54:51 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Sun Dec 18 19:12:12 2016 +0100

lvs: show status for layer

When LV is external origin, show info for LV but
status for -layer.  So we expose more info to a user
as otherwise active external origin is only linear
mapping of -real layer.

We do the same for i.e. old snaphost origin.
---
 WHATS_NEW               |    1 +
 lib/activate/activate.c |    7 +++++++
 2 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index eee6e98..93fc93e 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.169 - 
 =====================================
+  Improve reported lvs status for active external origin volume.
   Fix table load for splitted RAID LV and require explicit activation.
   Always active splitted RAID LV exclusively locally.
   Do not use LV RAID status bit for segment status.
diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index b4c8a2c..c554337 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -784,6 +784,13 @@ int lv_info_with_seg_status(struct cmd_context *cmd,
 				status->info.exists = 0; /* So pool LV is not active */
 		}
 		return 1;
+	} else if (lv_is_external_origin(lv)) {
+		if (!_lv_info(cmd, lv, 0, &status->info, NULL, NULL,
+			      with_open_count, with_read_ahead))
+			return_0;
+
+		(void) _lv_info(cmd, lv, 1, NULL, lv_seg, &status->seg_status, 0, 0);
+		return 1;
 	} else if (lv_is_origin(lv)) {
 		/* Query segment status for 'layered' (-real) device most of the time,
 		 * only for merging snapshot, query its progress.


