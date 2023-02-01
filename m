From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Wed,  1 Feb 2023 10:53:13 +0000 (GMT)
Subject: main - debug: compatibility with x32 ABI
Message-ID: <20230201105313.8AC5F3858298@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=0ec087e8b82848891512f100ff594add8f47cfb2
Commit:        0ec087e8b82848891512f100ff594add8f47cfb2
Parent:        c8a5948a71b041ae2cce03e1b3a9843f0fab023f
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jan 18 14:27:56 2023 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Wed Feb 1 11:47:47 2023 +0100

debug: compatibility with x32 ABI

Keep the conversion 64bit as on x32 arch time_t is 64bit value
and we may loose precision  (y2038).

TODO: like use universal string for time printing as in log/log.c
_set_time_prefix()
---
 daemons/dmeventd/libdevmapper-event.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/daemons/dmeventd/libdevmapper-event.c b/daemons/dmeventd/libdevmapper-event.c
index c6532b9a5..b5ae37fbc 100644
--- a/daemons/dmeventd/libdevmapper-event.c
+++ b/daemons/dmeventd/libdevmapper-event.c
@@ -928,8 +928,8 @@ void dm_event_log(const char *subsys, int level, const char *file,
 			start = now;
 		now -= start;
 		if (_debug_level)
-			fprintf(stream, "[%2ld:%02ld] %8x:%-6s%s",
-				(long)now / 60, (long)now % 60,
+			fprintf(stream, "[%2lld:%02lld] %8x:%-6s%s",
+				(long long)now / 60, (long long)now % 60,
 				// TODO: Maybe use shorter ID
 				// ((int)(pthread_self()) >> 6) & 0xffff,
 				(int)pthread_self(), subsys,

