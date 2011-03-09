From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed,  9 Mar 2011 13:18:34 +0100
Subject: [PATCH 3/4] Do not check already checked part
In-Reply-To: <cover.1299670163.git.zkabelac@redhat.com>
References: <cover.1299670163.git.zkabelac@redhat.com>
Message-ID: <cc232995c2292dc586069f16add546746f99c36e.1299670163.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

check_lv_segments is eithe called once - with 'complete_vg == 0'
or twice in row first with == 0, then with 1.

My assumtion is we do not need to make the same tests for same data
pointers twice - if we already know it's been been OK from the
first pass - that way it's used in vg_validate() and vg_read_internal().

Better idea would be probably to make rather 2 separte functions
there - but for now just skip some large piece of the code.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/metadata/merge.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/lib/metadata/merge.c b/lib/metadata/merge.c
index 3b8895c..402ee57 100644
--- a/lib/metadata/merge.c
+++ b/lib/metadata/merge.c
@@ -209,6 +209,9 @@ int check_lv_segments(struct logical_volume *lv, int complete_vg)
 		le += seg->len;
 	}
 
+	if (complete_vg)
+		goto out;
+
 	dm_list_iterate_items(sl, &lv->segs_using_this_lv) {
 		seg = sl->seg;
 		seg_found = 0;
-- 
1.7.4.1


