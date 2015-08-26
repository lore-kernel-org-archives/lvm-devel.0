From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Wed, 26 Aug 2015 09:29:18 +0000 (UTC)
Subject: master - cache: no report error for cpool without mode
Message-ID: <20150826092918.1533261188@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cbe81ad3932417ffaf89cbd924bd6d1ce1c7f199
Commit:        cbe81ad3932417ffaf89cbd924bd6d1ce1c7f199
Parent:        8c09f12943a8136079360a05bc0afc120cfc7674
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 25 14:47:07 2015 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Aug 26 10:49:23 2015 +0200

cache: no report error for cpool without mode

It's perferctly valid to not have cachemode for
unused cache-pool.

https://bugzilla.redhat.com/show_bug.cgi?id=1255184
---
 lib/report/report.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index a17af32..1885f45 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -2078,7 +2078,7 @@ static int _cachemode_disp(struct dm_report *rh, struct dm_pool *mem,
 	if (seg_is_cache(seg))
 		seg = first_seg(seg->pool_lv);
 
-	if (seg_is_cache_pool(seg)) {
+	if (seg_is_cache_pool(seg) && cache_mode_is_set(seg)) {
 		if (!(cachemode_str = get_cache_mode_name(seg)))
 			return_0;
 


