From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 4 Feb 2020 11:23:12 -0500
Subject: master - raid: add internal error for no segment
Message-ID: <71448.120020411230600249@us-mta-294.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=67f627c8fbcd5224a1439cbef590e488f6c4823b
Commit:        67f627c8fbcd5224a1439cbef590e488f6c4823b
Parent:        409362c127222640cd2d1fe3e1b62b50867741c1
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Jan 30 15:46:05 2020 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Feb 4 17:22:06 2020 +0100

raid: add internal error for no segment

clang: capture internal error when data_seg would not be defined.
(invalid LV with no areas)
---
 lib/metadata/raid_manip.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/lib/metadata/raid_manip.c b/lib/metadata/raid_manip.c
index 486dea1..dfc6fe5 100644
--- a/lib/metadata/raid_manip.c
+++ b/lib/metadata/raid_manip.c
@@ -4277,6 +4277,11 @@ static int _raid0_to_striped_retrieve_segments_and_lvs(struct logical_volume *lv
 				return_0;
 		}
 
+		if (!data_seg) {
+			log_error(INTERNAL_ERROR "No segment for %s.", display_lvname(lv));
+			return 0;
+		}
+
 		/* Presumes all data LVs have equal size */
 		area_le += data_seg->len;
 	}



