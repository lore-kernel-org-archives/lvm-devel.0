From: Milan Broz <mbroz@redhat.com>
Date: Sun, 31 May 2009 22:45:56 +0200
Subject: [PATCH] Fix log allocation segfault
Message-ID: <4A22EC84.7010209@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Fix log allocation segfault.

If there is no free area for log, code should break the loop.
(Otherwise it uses uninitializes areas later.)

Easily reproducible using lvconvert --repair
 - kill device with log
 - run lvconvert --repair vg/lv (with no PV usable for log)

(patch just reintroduces part of previous code)

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 lib/metadata/lv_manip.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index 79407ae..3e64f48 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -1124,6 +1124,10 @@ static int _find_parallel_space(struct alloc_handle *ah, alloc_policy_t alloc,
 		if ((contiguous || cling) && (preferred_count < ix_offset))
 			break;
 
+		if (ix + ix_offset < ah->area_count +
+			((ah->log_count && !ah->log_area.len) ? ah->log_count : 0))
+			break;
+
 		/* sort the areas so we allocate from the biggest */
 		if (ix > 1)
 			qsort(areas + ix_offset, ix, sizeof(*areas),




