From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 25 Mar 2014 10:23:34 +0000 (UTC)
Subject: master - clvmd: validate open device state
Message-ID: <20140325102334.D9C8E60F9D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=b714c7ebc618872abca1c6c7764c84c50b7fbcbe
Commit:        b714c7ebc618872abca1c6c7764c84c50b7fbcbe
Parent:        b522312678abaccd16b51299994e032d96a79267
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Mar 25 10:17:34 2014 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Mar 25 11:22:57 2014 +0100

clvmd: validate open device state

If clvmd does not hold any lock, it should also not keep any opened
device.

The reason for this patch is, that refresh_toolcontext calls
dev_cache_exit() which destroys whole device cache (even those with
opened file) - previous patch added recovery path to avoid memory
corruption, but opened files are still bugs that need to be fixed.

So this patch certainly kills many internal mirror & raid tests,
since they leak opened file descriptors (when tests are executed
with 'abort_on_error').
---
 daemons/clvmd/lvm-functions.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/daemons/clvmd/lvm-functions.c b/daemons/clvmd/lvm-functions.c
index 622eb79..4ce0fcc 100644
--- a/daemons/clvmd/lvm-functions.c
+++ b/daemons/clvmd/lvm-functions.c
@@ -182,6 +182,15 @@ static void remove_info(const char *resource)
 {
 	pthread_mutex_lock(&lv_hash_lock);
 	dm_hash_remove(lv_hash, resource);
+
+	/* When last lock is remove, validate there are not left opened devices */
+	if (!dm_hash_get_first(lv_hash)) {
+		if (dev_cache_check_for_open_devices())
+			log_error(INTERNAL_ERROR "Nothing is locked however there are still opened devices.");
+		if (critical_section())
+			log_error(INTERNAL_ERROR "Nothing is locked however clvmd is left in critical section.");
+	}
+
 	pthread_mutex_unlock(&lv_hash_lock);
 }
 


