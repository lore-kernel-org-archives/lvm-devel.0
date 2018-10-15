From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 15 Oct 2018 11:56:02 -0400
Subject: master - cov: ignore error of vsnprintf
Message-ID: <201810151556.w9FFu211020729@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=43e4bfe428cb4e8a953a74aeca5b1942ce6f55a4
Commit:        43e4bfe428cb4e8a953a74aeca5b1942ce6f55a4
Parent:        84f00f50584b0c1c0464a414c71cd112e4d30c22
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Oct 15 17:37:30 2018 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Oct 15 17:49:44 2018 +0200

cov: ignore error of vsnprintf

---
 device_mapper/vdo/status.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/device_mapper/vdo/status.c b/device_mapper/vdo/status.c
index 6ae7b84..53dfe4d 100644
--- a/device_mapper/vdo/status.c
+++ b/device_mapper/vdo/status.c
@@ -154,7 +154,7 @@ static void _set_error(struct dm_vdo_status_parse_result *result, const char *fm
 	va_list ap;
 
 	va_start(ap, fmt);
-	vsnprintf(result->error, sizeof(result->error), fmt, ap);
+	(void) vsnprintf(result->error, sizeof(result->error), fmt, ap);
 	va_end(ap);
 }
 


