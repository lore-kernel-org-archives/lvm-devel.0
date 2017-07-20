From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Thu, 20 Jul 2017 06:18:44 -0400
Subject: master - dmsetup: simplify check of parsed cookie value
Message-ID: <201707201018.v6KAIioF016454@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=e769e3d3bfd5eaccd5a9043b5641bc73550e5528
Commit:        e769e3d3bfd5eaccd5a9043b5641bc73550e5528
Parent:        86d7adc2a587228f30c4fbceed82005ccd7b0efb
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Jul 19 22:04:37 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Jul 20 11:18:16 2017 +0200

dmsetup: simplify check of parsed cookie value

Improving parsing error detection for strtoul.
---
 tools/dmsetup.c |   11 +++++------
 1 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 2eed39e..69649ae 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -1396,15 +1396,14 @@ static uint32_t _get_cookie_value(const char *str_value)
 	char *p;
 
 	errno = 0;
-	if (!(value = strtoul(str_value, &p, 0)) ||
-	    *p ||
-	    (value == ULONG_MAX && errno == ERANGE) ||
-	    value > 0xFFFFFFFF) {
+	value = strtoul(str_value, &p, 0);
+
+	if (errno || !value || (*p) || (value > UINT32_MAX)) {
 		err("Incorrect cookie value");
 		return 0;
 	}
-	else
-		return (uint32_t) value;
+
+	return (uint32_t) value;
 }
 
 static int _udevflags(CMD_ARGS)


