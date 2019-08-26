From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 26 Aug 2019 09:40:04 -0400
Subject: stable-2.02 - dmsetup: missed trailing newline
Message-ID: <201908261340.x7QDe4oK005681@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=93de9b59c21e6a3b29ccaa6425fde50a9053bdc2
Commit:        93de9b59c21e6a3b29ccaa6425fde50a9053bdc2
Parent:        e03bdd7556289ef130c6e173e86207e2a3d765c9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Aug 26 15:37:57 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Aug 26 15:38:20 2019 +0200

dmsetup: missed trailing newline

---
 tools/dmsetup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 5b21620..60e0638 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -1694,7 +1694,7 @@ static int _udevcomplete(CMD_ARGS)
 	if (!(cookie = _get_cookie_value(argv[0])))
 		return_0;
 
-	printf("DM_COOKIE_COMPLETED=0x%-10x", cookie);
+	printf("DM_COOKIE_COMPLETED=0x%-10x\n", cookie);
 	/*
 	 * Strip flags from the cookie and use cookie magic instead.
 	 * If the cookie has non-zero prefix and the base is zero then


