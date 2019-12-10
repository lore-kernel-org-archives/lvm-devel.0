From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Tue, 10 Dec 2019 09:46:51 -0500
Subject: master - test: fix missing waiting on udev
Message-ID: <90862.119121009464700583@us-mta-18.us.mimecast.lan>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=611d4107a4b3c434c4266ae6f2638927541bc9b6
Commit:        611d4107a4b3c434c4266ae6f2638927541bc9b6
Parent:        3b6defcf1fb20d3a9b2fb4f407e9abd4a8291bb0
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Dec 10 13:40:56 2019 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Dec 10 15:44:16 2019 +0100

test: fix missing waiting on udev

After device creation we need to wait for a cookie so it's not forgotten
in the system.
---
 test/lib/dmsecuretest.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/test/lib/dmsecuretest.c b/test/lib/dmsecuretest.c
index d90546c..19265bf 100644
--- a/test/lib/dmsecuretest.c
+++ b/test/lib/dmsecuretest.c
@@ -48,6 +48,7 @@ int main (int argc, char *argv[])
 	char aes[] = "434r0pono02pn68sson9268222p3789q703sr62427o78o308518o3228s6n2122";
 	const char *device = (argc > 1) ? argv[1] : "/dev/loop0";  /* device for use */
 	const char *devname = (argc > 2) ? argv[2] : "test-secure"; /* name of dm device */
+	const char *cipher = (argc > 3) ? argv[3] : "aes-xts-plain64"; /* name of dm device */
 	uint32_t cookie = 0;
 	char table[300];
 	struct dm_task *dmt;
@@ -63,7 +64,7 @@ int main (int argc, char *argv[])
 		(void) dm_task_set_name(dmt, devname);
 		(void) dm_task_secure_data(dmt);
 		rot13(aes);
-		snprintf(table, sizeof(table), "aes-xts-plain64 %s 0 %s %u", aes, device, sz);
+		snprintf(table, sizeof(table), "%s %s 0 %s %u", cipher, aes, device, sz);
 		memset(aes, 0, sizeof(aes));
 		(void) dm_task_add_target(dmt, 0, sz, "crypt", table);
 		memset(table, 0, sizeof(table));
@@ -71,10 +72,9 @@ int main (int argc, char *argv[])
 		(void) dm_task_set_cookie(dmt, &cookie, DM_UDEV_DISABLE_LIBRARY_FALLBACK);
 		(void) dm_task_run(dmt);
 		(void) dm_task_destroy(dmt);
+		(void) dm_udev_wait(cookie); /* Finish udev processing */
 	}
 
-	dm_task_update_nodes();
-
 	/* At this point there should be no memory trace from a secure table line */
 
 #ifdef SLEEP



