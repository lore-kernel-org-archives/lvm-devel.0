From: David Teigland <teigland@fedoraproject.org>
Date: Mon, 22 Sep 2014 15:39:44 +0000 (UTC)
Subject: dev-dct-process-latest - cleanup: use int32 for major minor
Message-ID: <20140922153944.93B6D615CC@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=18b8fdc8c92f54c39b8089c343d6fc12fafd1f38
Commit:        18b8fdc8c92f54c39b8089c343d6fc12fafd1f38
Parent:        d274724c83e0bed34b4a1d794a6eb16cab777c05
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Sep 19 17:04:28 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Sep 19 17:04:28 2014 +0200

cleanup: use int32 for major minor

Use consistently int32_t for major, minor.
---
 lib/metadata/metadata-exported.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index aa0edcf..0fa6c97 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -797,8 +797,8 @@ struct lvcreate_params {
 	int create_pool; /* thin */
 	int zero; /* all */
 	int wipe_signatures; /* all */
-	int major; /* all */
-	int minor; /* all */
+	int32_t major; /* all */
+	int32_t minor; /* all */
 	int log_count; /* mirror */
 	int nosync; /* mirror */
 	int poolmetadataspare; /* thin pool */


