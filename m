From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 20 Aug 2019 06:53:28 -0400
Subject: master - dmsetup: debug print
Message-ID: <201908201053.x7KArSr5017991@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a18f562913aaebf4587531fb40082718ec504f7a
Commit:        a18f562913aaebf4587531fb40082718ec504f7a
Parent:        30a98e4d6710a543692d40d11428ae4baea11b7b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 16 23:49:38 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 20 12:50:44 2019 +0200

dmsetup: debug print

Udev debugging is a bit tricky, so to more easily pair cookie ID,
which is the lowest 16 bit - print cookie as hexa number.
This simplify pairing of processed cookies while the 'higher bit flags'
are changed for the same cookie.
---
 WHATS_NEW_DM             |    1 +
 libdm/dm-tools/dmsetup.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 2c0c7ec..60a2b53 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.165 - 
 =================================
+  Add debug of dmsetup udevcomplete with hexa print DM_COOKIE_COMPLETED.
   Fix versioning of dm_stats_create_region and dm_stats_create_region.
 
 Version 1.02.163 - 15th June 2019
diff --git a/libdm/dm-tools/dmsetup.c b/libdm/dm-tools/dmsetup.c
index 928b599..a38df6b 100644
--- a/libdm/dm-tools/dmsetup.c
+++ b/libdm/dm-tools/dmsetup.c
@@ -1695,6 +1695,7 @@ static int _udevcomplete(CMD_ARGS)
 	if (!(cookie = _get_cookie_value(argv[0])))
 		return_0;
 
+	printf("DM_COOKIE_COMPLETED=0x%-10x", cookie);
 	/*
 	 * Strip flags from the cookie and use cookie magic instead.
 	 * If the cookie has non-zero prefix and the base is zero then


