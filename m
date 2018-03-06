From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 6 Mar 2018 09:46:02 -0500
Subject: master - debug: update comment
Message-ID: <201803061446.w26Ek2bJ026703@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=6481471c9d74038da457b74ef1f2b0c15931bfa8
Commit:        6481471c9d74038da457b74ef1f2b0c15931bfa8
Parent:        b6e7a0b490a3fa2e43675a4d3fb3d25daaac831e
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Mar 2 15:06:36 2018 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 6 15:40:34 2018 +0100

debug: update comment

---
 lib/metadata/lv_manip.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index d4a6107..915a032 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -4371,9 +4371,9 @@ static int _for_each_sub_lv(struct logical_volume *lv, int level,
 	if (level++) {
 		if (!(r = fn(lv, data)))
 			return_0;
-		/* Only r == 1 lets you run for_each... */
 		if (r == -1)
 			return 1;
+		/* Only r != -1 continues with for_each_sub_lv()... */
 	}
 
 	if (lv_is_cow(lv) && lv_is_virtual_origin(org = origin_from_cow(lv))) {


