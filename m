From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 26 Aug 2019 11:26:13 -0400
Subject: master - dmsetup: missed trailing newline
Message-ID: <201908261526.x7QFQDIO009028@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=a50c127904a99b5862c323ddc76bfcf760dd0805
Commit:        a50c127904a99b5862c323ddc76bfcf760dd0805
Parent:        4b1dcc2eebb27cae54b4c618ab31072bdb230ea9
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Aug 26 15:37:57 2019 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Aug 26 17:22:58 2019 +0200

dmsetup: missed trailing newline

---
 libdm/dm-tools/dmsetup.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/dm-tools/dmsetup.c b/libdm/dm-tools/dmsetup.c
index a38df6b..2f8a1be 100644
--- a/libdm/dm-tools/dmsetup.c
+++ b/libdm/dm-tools/dmsetup.c
@@ -1695,7 +1695,7 @@ static int _udevcomplete(CMD_ARGS)
 	if (!(cookie = _get_cookie_value(argv[0])))
 		return_0;
 
-	printf("DM_COOKIE_COMPLETED=0x%-10x", cookie);
+	printf("DM_COOKIE_COMPLETED=0x%-10x\n", cookie);
 	/*
 	 * Strip flags from the cookie and use cookie magic instead.
 	 * If the cookie has non-zero prefix and the base is zero then


