From: David Teigland <teigland@sourceware.org>
Date: Fri, 19 Nov 2021 18:04:01 +0000 (GMT)
Subject: main - fix spelling of pruning
Message-ID: <20211119180401.665873858418@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=114e1cfee532eac7d594549f68f21e9f6ee67dc5
Commit:        114e1cfee532eac7d594549f68f21e9f6ee67dc5
Parent:        212b1fc529a7d550c49f32cb7cbecb017ceb35b0
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Fri Nov 19 12:02:35 2021 -0600
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Fri Nov 19 12:02:35 2021 -0600

fix spelling of pruning

---
 lib/format_text/archive.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/format_text/archive.c b/lib/format_text/archive.c
index 09a472b4c..2e8792a93 100644
--- a/lib/format_text/archive.c
+++ b/lib/format_text/archive.c
@@ -219,7 +219,7 @@ static void _remove_expired(const char *dir, const char *vgname,
 
 	sum /= 1024 * 1024;
 	if (sum > 128 || archives_size > 8192)
-		log_print_unless_silent("Consider prunning %s VG archive with more then %u MiB in %u files (check archiving is needed in lvm.conf).",
+		log_print_unless_silent("Consider pruning %s VG archive with more then %u MiB in %u files (check archiving is needed in lvm.conf).",
 					vgname, (unsigned)sum, archives_size);
 }
 


