From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 16 Jan 2023 11:39:11 +0000 (GMT)
Subject: main - lvresize: use standard extent conversion function
Message-ID: <20230116113911.CD2673858D32@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f486eb60d5cfb72f084b9e2c02e4dc962f26bb69
Commit:        f486eb60d5cfb72f084b9e2c02e4dc962f26bb69
Parent:        bb34ebd4e4facb3a12b799bc0541af798e091459
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 10 18:09:51 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jan 16 12:35:00 2023 +0100

lvresize: use standard extent conversion function

We need to validate whether the requested resizing size can be
expressed with given extent_size.
---
 lib/metadata/lv_manip.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/lib/metadata/lv_manip.c b/lib/metadata/lv_manip.c
index f8eae0447..305be8578 100644
--- a/lib/metadata/lv_manip.c
+++ b/lib/metadata/lv_manip.c
@@ -5197,7 +5197,8 @@ static int _lvresize_adjust_size(struct volume_group *vg,
 					display_size(vg->cmd, size));
 	}
 
-	*extents = size / extent_size;
+	if (!(*extents = extents_from_size(vg->cmd, size, extent_size)))
+		return_0;
 
 	return 1;
 }

