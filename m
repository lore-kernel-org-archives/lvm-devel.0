From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri,  4 Dec 2015 21:11:39 +0000 (UTC)
Subject: master - libdm: add some doc for mirror status
Message-ID: <20151204211139.2176660515@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=45781161f49dcd9b31909ec40766ab4e71d0afa0
Commit:        45781161f49dcd9b31909ec40766ab4e71d0afa0
Parent:        c24d913c47d9639df277b613cee9b5a57aca0762
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Dec 4 20:24:47 2015 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Dec 4 22:10:30 2015 +0100

libdm: add some doc for mirror status

Comment content of struct for mirror status.
---
 libdm/libdevmapper.h |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 48f8682..12a665b 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -300,19 +300,19 @@ typedef enum {
 struct dm_status_mirror {
 	uint64_t total_regions;
 	uint64_t insync_regions;
-	uint32_t dev_count;
+	uint32_t dev_count;             /* # of devs[] elements (<= 8) */
 	struct {
 		dm_status_mirror_health_t health;
 		uint32_t major;
 		uint32_t minor;
-	} *devs;
-	const char *log_type;
-	uint32_t log_count;
+	} *devs;                        /* array with individual legs */
+	const char *log_type;           /* core, disk,.... */
+	uint32_t log_count;		/* # of logs[] elements */
 	struct {
 		dm_status_mirror_health_t health;
 		uint32_t major;
 		uint32_t minor;
-	} *logs;
+	} *logs;			/* array with individual logs */
 };
 
 int dm_get_status_mirror(struct dm_pool *mem, const char *params,


