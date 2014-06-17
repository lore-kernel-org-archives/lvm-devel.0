From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 17 Jun 2014 13:24:39 +0000 (UTC)
Subject: master - cleanup: use stack for small buffer
Message-ID: <20140617132439.DC43D61207@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=7aef45f9bb8620e194d086ebeeaca0312e8aee04
Commit:        7aef45f9bb8620e194d086ebeeaca0312e8aee04
Parent:        494db110040cdc88ebf60abee87b04c6c8718cea
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 16 12:38:14 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Jun 17 13:42:45 2014 +0200

cleanup: use stack for small buffer

Avoid error checking of allocation error when just few bytes are needed
for short string and use stack.
Stacktrace lvmetad_pv_gone() fail path.
---
 tools/pvscan.c |   15 ++++++---------
 1 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/tools/pvscan.c b/tools/pvscan.c
index ac43295..d161ba0 100644
--- a/tools/pvscan.c
+++ b/tools/pvscan.c
@@ -164,18 +164,15 @@ out:
 static int _clear_dev_from_lvmetad_cache(dev_t devno, int32_t major, int32_t minor,
 					 activation_handler handler)
 {
-	char *buf;
+	char buf[24];
 
-	if (dm_asprintf(&buf, "%" PRIi32 ":%" PRIi32, major, minor) < 0)
-		stack;
-	if (!lvmetad_pv_gone(devno, buf ? : "", handler)) {
-		dm_free(buf);
-		return 0;
-	}
+	(void) dm_snprintf(buf, sizeof(buf), "%" PRIi32 ":%" PRIi32, major, minor);
+
+	if (!lvmetad_pv_gone(devno, buf, handler))
+		return_0;
 
 	log_print_unless_silent("Device %s not found. "
-				"Cleared from lvmetad cache.", buf ? : "");
-	dm_free(buf);
+				"Cleared from lvmetad cache.", buf);
 
 	return 1;
 }


