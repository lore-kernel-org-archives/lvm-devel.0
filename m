From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed,  5 Nov 2014 14:33:27 +0000 (UTC)
Subject: master - snapshot: no snapshot of any cache type LVs
Message-ID: <20141105143327.8B06260E61@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a82dcadf66dbd43a43d3be40cd62a5074248d218
Commit:        a82dcadf66dbd43a43d3be40cd62a5074248d218
Parent:        3261e539a01efffb56abd78e5a060af8d1cf1537
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Nov 4 23:21:07 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Nov 5 15:28:38 2014 +0100

snapshot: no snapshot of any cache type LVs

Unsupported as of now.
---
 WHATS_NEW               |    1 +
 lib/metadata/lv_manip.c |    6 ++++++
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 8acbc3d..03baa06 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.112 - 
 =====================================
+  Properly report error when taking snapshot of any cache type LV.
   Add basic thread debugging messages to dmeventd.
   Include threads being shutdown in dmeventd device registration responses.
   Inital support for external users of thin pools based on transaction_id.
diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d3c0c47..6cf51f9 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -6804,6 +6804,12 @@ static struct logical_volume *_lv_create_an_lv(struct volume_group *vg,
 				return NULL;
 			}
 
+			if (lv_is_cache_type(origin_lv)) {
+				log_error("Snapshots of cache type volume %s "
+					  "is not supported.", display_lvname(origin_lv));
+				return NULL;
+			}
+
 			if (lv_is_thin_type(origin_lv) && !lv_is_thin_volume(origin_lv)) {
 				log_error("Snapshots of thin pool %sdevices "
 					  "are not supported.",


