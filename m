From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  1 Feb 2023 10:53:10 +0000 (GMT)
Subject: main - archive: update message
Message-ID: <20230201105310.2654E3857C43@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=f89c369a0119a701a5a550694258a145202ab4a2
Commit:        f89c369a0119a701a5a550694258a145202ab4a2
Parent:        6d14144d311fb347e4225ad6a48d4900b39445c4
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Jan 17 23:58:41 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 1 11:47:30 2023 +0100

archive: update message

Better suggesting message as suggested by RHBZ 2123151.
---
 lib/format_text/archive.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/format_text/archive.c b/lib/format_text/archive.c
index 2e8792a93..5acf0c04a 100644
--- a/lib/format_text/archive.c
+++ b/lib/format_text/archive.c
@@ -219,7 +219,7 @@ static void _remove_expired(const char *dir, const char *vgname,
 
 	sum /= 1024 * 1024;
 	if (sum > 128 || archives_size > 8192)
-		log_print_unless_silent("Consider pruning %s VG archive with more then %u MiB in %u files (check archiving is needed in lvm.conf).",
+		log_print_unless_silent("Consider pruning %s VG archive with more then %u MiB in %u files (see archiving settings in lvm.conf).",
 					vgname, (unsigned)sum, archives_size);
 }
 

