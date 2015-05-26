From: okozina <okozina@fedoraproject.org>
Date: Tue, 26 May 2015 14:29:43 +0000 (UTC)
Subject: master - lvconvert.c: fix whitespace mess
Message-ID: <20150526142943.66D3060080@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=a72a80589689961285ec6aacff99087ddd8c378d
Commit:        a72a80589689961285ec6aacff99087ddd8c378d
Parent:        eeb498627c46626c782cb6a2f0e54eb011da8b8e
Author:        Ondrej Kozina <okozina@redhat.com>
AuthorDate:    Mon May 25 13:16:57 2015 +0200
Committer:     Ondrej Kozina <okozina@redhat.com>
CommitterDate: Tue May 26 16:26:57 2015 +0200

lvconvert.c: fix whitespace mess

---
 tools/lvconvert.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index 4c0cb10..fe8b761 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -840,7 +840,7 @@ static int _failed_mirrors_count(struct logical_volume *lv)
 				else if (seg_lv(lvseg, s)->status & PARTIAL_LV)
 					++ ret;
 			}
-		   	else if (seg_type(lvseg, s) == AREA_PV &&
+			else if (seg_type(lvseg, s) == AREA_PV &&
 				 is_missing_pv(seg_pv(lvseg, s)))
 				++ret;
 		}


