From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 18 Feb 2016 15:50:18 +0000 (UTC)
Subject: master - libdm: thin status update
Message-ID: <20160218155018.AF69B60D32@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0fb3669d49040ea2e616491326eecad9926048c8
Commit:        0fb3669d49040ea2e616491326eecad9926048c8
Parent:        ecfa465366d2d6f2a995111eef3c8dac3987c2ef
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Feb 15 16:33:38 2016 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Feb 18 16:45:42 2016 +0100

libdm: thin status update

Fix parsing of 'Fail' status (using capital letter) for thin-pool.
Add also parsing of 'Error' state for thin-pool.
Add needs_check test for thin-pool.

Detect Fail state for thin.
---
 WHATS_NEW_DM          |    1 +
 libdm/libdevmapper.h  |    8 ++++++--
 libdm/libdm-targets.c |   29 ++++++++++++++++++++++-------
 3 files changed, 29 insertions(+), 9 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index d82ebf3..984d7fa 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.117 - 
 =====================================
+  Improve status parsing for thin-pool and thin devices.
 
 Version 1.02.116 - 15th February 2016
 =====================================
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index fcbc8ce..0b7d5ba 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -406,8 +406,10 @@ struct dm_status_thin_pool {
 	dm_thin_discards_t discards;
 	uint32_t fail : 1;		/* all I/O fails */
 	uint32_t error_if_no_space : 1;	/* otherwise queue_if_no_space */
-	uint32_t out_of_data_space : 1;	/* metadata may be changed, but data may not be allocated */
-	uint32_t reserved : 29;
+	uint32_t out_of_data_space : 1;	/* metadata may be changed, but data may not be allocated (no rw) */
+	uint32_t needs_check : 1;	/* metadata needs check */
+	uint32_t error : 1;		/* detected error (switches to fail soon) */
+	uint32_t reserved : 27;
 };
 
 int dm_get_status_thin_pool(struct dm_pool *mem, const char *params,
@@ -417,6 +419,8 @@ int dm_get_status_thin_pool(struct dm_pool *mem, const char *params,
 struct dm_status_thin {
 	uint64_t mapped_sectors;
 	uint64_t highest_mapped_sector;
+	uint32_t fail : 1;              /* Thin volume fails I/O */
+	uint32_t reserved : 31;
 };
 
 int dm_get_status_thin(struct dm_pool *mem, const char *params,
diff --git a/libdm/libdm-targets.c b/libdm/libdm-targets.c
index 16d4f6b..7428eba 100644
--- a/libdm/libdm-targets.c
+++ b/libdm/libdm-targets.c
@@ -278,6 +278,17 @@ int parse_thin_pool_status(const char *params, struct dm_status_thin_pool *s)
 		return 0;
 	}
 
+	if (strstr(params, "Error")) {
+		s->error = 1;
+		s->fail = 1; /*  This is also I/O fail state */
+		return 1;
+	}
+
+	if (strstr(params, "Fail")) {
+		s->fail = 1;
+		return 1;
+	}
+
 	/* FIXME: add support for held metadata root */
 	if (sscanf(params, FMTu64 " " FMTu64 "/" FMTu64 " " FMTu64 "/" FMTu64 "%n",
 		   &s->transaction_id,
@@ -297,16 +308,19 @@ int parse_thin_pool_status(const char *params, struct dm_status_thin_pool *s)
 	else /* default discard_passdown */
 		s->discards = DM_THIN_DISCARDS_PASSDOWN;
 
-	if (strstr(params + pos, "ro "))
-		s->read_only = 1;
-	else if (strstr(params + pos, "fail"))
-		s->fail = 1;
-	else if (strstr(params + pos, "out_of_data_space"))
+	/* Default is 'writable' (rw) data */
+	if (strstr(params + pos, "out_of_data_space"))
 		s->out_of_data_space = 1;
+	else if (strstr(params + pos, "ro "))
+		s->read_only = 1;
 
+	/* Default is 'queue_if_no_space' */
 	if (strstr(params + pos, "error_if_no_space"))
 		s->error_if_no_space = 1;
 
+	if (strstr(params + pos, "needs_check"))
+		s->needs_check = 1;
+
 	return 1;
 }
 
@@ -341,8 +355,9 @@ int dm_get_status_thin(struct dm_pool *mem, const char *params,
 	}
 
 	if (strchr(params, '-')) {
-		s->mapped_sectors = 0;
-		s->highest_mapped_sector = 0;
+		/* nothing to parse */
+	} else if (strstr(params, "Fail")) {
+		s->fail = 1;
 	} else if (sscanf(params, FMTu64 " " FMTu64,
 		   &s->mapped_sectors,
 		   &s->highest_mapped_sector) != 2) {


