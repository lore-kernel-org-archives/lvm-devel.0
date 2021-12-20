From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 20 Dec 2021 15:14:08 +0000 (GMT)
Subject: main - activate: cache driver_version result
Message-ID: <20211220151408.56F903858438@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=47ac2659d5f8544dcd53aeef13a42b3256f2fd6f
Commit:        47ac2659d5f8544dcd53aeef13a42b3256f2fd6f
Parent:        26e6580dfb00912823282f7028ab542501c449ef
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Wed Dec 8 10:25:02 2021 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Dec 20 16:13:28 2021 +0100

activate: cache driver_version result

---
 lib/activate/activate.c | 10 +++++++++-
 1 file changed, 9 insertions(+), 1 deletion(-)

diff --git a/lib/activate/activate.c b/lib/activate/activate.c
index 727bd2386..52ec02e2c 100644
--- a/lib/activate/activate.c
+++ b/lib/activate/activate.c
@@ -486,12 +486,20 @@ int library_version(char *version, size_t size)
 
 int driver_version(char *version, size_t size)
 {
+	static char _vsn[80] = { 0 };
+
 	if (!activation())
 		return 0;
 
 	log_very_verbose("Getting driver version");
 
-	return dm_driver_version(version, size);
+	if (!_vsn[0] &&
+	    !dm_driver_version(_vsn, sizeof(_vsn)))
+		return_0;
+
+	(void) dm_strncpy(version, _vsn, size);
+
+	return 1;
 }
 
 int target_version(const char *target_name, uint32_t *maj,


