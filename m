From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 20 Dec 2022 15:23:36 +0000 (GMT)
Subject: main - cov: use long type for time_t calcs
Message-ID: <20221220152336.98AA13858000@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=8f091d379860cf71577629cc1f56191b5f418310
Commit:        8f091d379860cf71577629cc1f56191b5f418310
Parent:        f443d16fd7409b46b77be2aa74090ab558c51425
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Dec 20 14:11:57 2022 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 20 15:04:36 2022 +0100

cov: use long type for time_t calcs

Some for y38k - calculations can handle 64b time_t.
---
 daemons/dmeventd/libdevmapper-event.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index 30df1da21..c6532b9a5 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -928,8 +928,8 @@ void dm_event_log(const char *subsys, int level, const char *file,
 			start = now;
 		now -= start;
 		if (_debug_level)
-			fprintf(stream, "[%2d:%02d] %8x:%-6s%s",
-				(int)now / 60, (int)now % 60,
+			fprintf(stream, "[%2ld:%02ld] %8x:%-6s%s",
+				(long)now / 60, (long)now % 60,
 				// TODO: Maybe use shorter ID
 				// ((int)(pthread_self()) >> 6) & 0xffff,
 				(int)pthread_self(), subsys,

