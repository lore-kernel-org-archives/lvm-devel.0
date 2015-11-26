From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 26 Nov 2015 20:28:15 +0000 (UTC)
Subject: master - debug: show LV name where dlid creation failed
Message-ID: <20151126202815.89E5B60B40@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=82ec3e5e93f5017d7c9a83197e34f05e783fa7bf
Commit:        82ec3e5e93f5017d7c9a83197e34f05e783fa7bf
Parent:        922fccc6560706f5026d59e383b694f9d7f85945
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Nov 26 21:20:33 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Nov 26 21:20:33 2015 +0100

debug: show LV name where dlid creation failed

---
 lib/misc/lvm-string.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/lib/misc/lvm-string.c b/lib/misc/lvm-string.c
index 5d63858..5bdb549 100644
--- a/lib/misc/lvm-string.c
+++ b/lib/misc/lvm-string.c
@@ -211,6 +211,7 @@ char *build_dm_uuid(struct dm_pool *mem, const struct logical_volume *lv,
 		    const char *layer)
 {
 	const char *lvid = lv->lvid.s;
+	const char *dlid;
 
 	if (!layer) {
 		/*
@@ -235,5 +236,9 @@ char *build_dm_uuid(struct dm_pool *mem, const struct logical_volume *lv,
 			NULL;
 	}
 
-	return dm_build_dm_uuid(mem, UUID_PREFIX, lvid, layer);
+	if (!(dlid = dm_build_dm_uuid(mem, UUID_PREFIX, lvid, layer)))
+		log_error("Failed to build LVM dlid for %s.",
+			  display_lvname(lv));
+
+	return dlid;
 }


