From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 May 2015 13:37:16 +0000 (UTC)
Subject: master - lvconvert: change how to get failed mirrors number
Message-ID: <20150522133716.E3DDB60EF4@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=9d558fbcc232314dc93a405b4da3079f5d8e9cb7
Commit:        9d558fbcc232314dc93a405b4da3079f5d8e9cb7
Parent:        ba68aed8366c201ab0a263a9935243a9e6f08875
Author:        Lidong Zhong <lzhong@suse.com>
AuthorDate:    Fri May 22 15:50:42 2015 +0800
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri May 22 15:35:36 2015 +0200

lvconvert: change how to get failed mirrors number

Commit  b00711e3128c9cb38da90f303a3b64cf3a30fc9b improperly
convert _area_missing() replacment and moved check for
AREA_PV seg_type() into same if() section.

Signed-off-by: Lidong Zhong <lzhong@suse.com>
---
 WHATS_NEW         |    1 +
 tools/lvconvert.c |    6 +++---
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index eecdca9..e5864eb 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.121 - 
 ================================
+  Fix test for AREA_PV when checking for failed mirrors.
   Do not use --sysinit in lvm2-activation{-early,-net}.service if lvmpolld used.
   Do not fail polling when poll LV not found (already finished or removed).
   Replace poll_get_copy_vg/lv fns with vg_read() and find_lv() in polldaemon.
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
 


