From: Lidong Zhong <lzhong@suse.com>
Date: Fri, 22 May 2015 15:50:42 +0800
Subject: [PATCH] lvconvert: change how to get failed mirrors number
Message-ID: <1432281042-8691-1-git-send-email-lzhong@suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

It's probably a typo since the segment type can't be AREA_LV and AREA_PV
simultaneously.

Signed-off-by: Lidong Zhong <lzhong@suse.com>
---
 tools/lvconvert.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 6e47f81..4c0cb10 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -839,10 +839,10 @@ static int _failed_mirrors_count(struct logical_volume *lv)
 					ret += _failed_mirrors_count(seg_lv(lvseg, s));
 				else if (seg_lv(lvseg, s)->status & PARTIAL_LV)
 					++ ret;
-				else if (seg_type(lvseg, s) == AREA_PV &&
-					 is_missing_pv(seg_pv(lvseg, s)))
-					++ret;
 			}
+		   	else if (seg_type(lvseg, s) == AREA_PV &&
+				 is_missing_pv(seg_pv(lvseg, s)))
+				++ret;
 		}
 	}
 
-- 
1.8.1.4


