From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 27 Jul 2021 22:50:37 +0000 (GMT)
Subject: main - cov: add explicit check for vg existence
Message-ID: <20210727225037.9FAAE385040A@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a4eb378fe41218793f4c7e97b0d82d33643b5a67
Commit:        a4eb378fe41218793f4c7e97b0d82d33643b5a67
Parent:        f4b49dae1eb982e36e748fa8e1fc2af59025c9c7
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jul 27 17:03:38 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Jul 28 00:49:28 2021 +0200

cov: add explicit check for vg existence

Since we check !vg - add check before accessing ->status.
---
 lib/format_text/format-text.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/format_text/format-text.c b/lib/format_text/format-text.c
index 26e55cec4..0441342a1 100644
--- a/lib/format_text/format-text.c
+++ b/lib/format_text/format-text.c
@@ -454,7 +454,7 @@ static struct volume_group *_vg_read_raw_area(struct cmd_context *cmd,
 			   (unsigned long long)rlocn->size,
 			   vgname);
 
-	if (precommitted)
+	if (vg && precommitted)
 		vg->status |= PRECOMMITTED;
 
       out:


