From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 20 Aug 2019 07:02:25 -0400
Subject: stable-2.02 - dmsetup: debug print
Message-ID: <201908201102.x7KB2PtJ018507@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=53fcd4fd8fdca852bd8db079f943594c4deeded5
Commit:        53fcd4fd8fdca852bd8db079f943594c4deeded5
Parent:        ba629ceea194cc964a6dddb84641254776e58e16
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 16 23:49:38 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 20 12:59:05 2019 +0200

dmsetup: debug print

Udev debugging is a bit tricky, so to more easily pair cookie ID,
which is the lowest 16 bit - print cookie as hexa number.
This simplify pairing of processed cookies while the 'higher bit flags'
are changed for the same cookie.
---
 WHATS_NEW_DM    |    5 +++--
 tools/dmsetup.c |    1 +
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 718d174..1dc18ec 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
-Version 1.02.160 - 
-================================
+Version 1.02.165 - 
+=================================
+  Add debug of dmsetup udevcomplete with hexa print DM_COOKIE_COMPLETED.
   Fix versioning of dm_stats_create_region and dm_stats_create_region.
   Parsing of cache status understand no_discard_passdown.
 
diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index bd080b8..5b21620 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -1694,6 +1694,7 @@ static int _udevcomplete(CMD_ARGS)
 	if (!(cookie = _get_cookie_value(argv[0])))
 		return_0;
 
+	printf("DM_COOKIE_COMPLETED=0x%-10x", cookie);
 	/*
 	 * Strip flags from the cookie and use cookie magic instead.
 	 * If the cookie has non-zero prefix and the base is zero then


