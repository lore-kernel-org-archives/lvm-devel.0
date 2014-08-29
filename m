From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 29 Aug 2014 11:12:41 +0000 (UTC)
Subject: master - cleanup: drop duplicate const
Message-ID: <20140829111241.4AD8C60FC3@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=2a0ec5d3968414bff251f1750e911c9dd120ca69
Commit:        2a0ec5d3968414bff251f1750e911c9dd120ca69
Parent:        19375e4fcabea7ffcf2b249f6738218b3885c871
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 29 11:51:53 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Aug 29 13:11:34 2014 +0200

cleanup: drop duplicate const

No need to specify 'const' twice in these cases.
---
 lib/raid/raid.c     |    2 +-
 lib/report/report.c |   10 +++++-----
 lib/thin/thin.c     |    2 +-
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/lib/raid/raid.c b/lib/raid/raid.c
index 5aad447..831c912 100644
--- a/lib/raid/raid.c
+++ b/lib/raid/raid.c
@@ -335,7 +335,7 @@ static int _raid_target_present(struct cmd_context *cmd,
 		uint32_t min;
 		unsigned raid_feature;
 		const char *feature;
-	} const _features[] = {
+	} _features[] = {
 		{ 1, 3, RAID_FEATURE_RAID10, "raid10" },
 	};
 
diff --git a/lib/report/report.c b/lib/report/report.c
index 84ca73b..f315df4 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -54,11 +54,11 @@ enum {
 
 static const uint64_t _zero64 = UINT64_C(0);
 static const uint64_t _one64 = UINT64_C(1);
-static const char const _str_zero[] = "0";
-static const char const _str_one[] = "1";
-static const char const _str_no[] = "no";
-static const char const _str_yes[] = "yes";
-static const char const _str_unknown[] = "unknown";
+static const char _str_zero[] = "0";
+static const char _str_one[] = "1";
+static const char _str_no[] = "no";
+static const char _str_yes[] = "yes";
+static const char _str_unknown[] = "unknown";
 
 /*
  * 32 bit signed is casted to 64 bit unsigned in dm_report_field internally!
diff --git a/lib/thin/thin.c b/lib/thin/thin.c
index 020ccc1..6982782 100644
--- a/lib/thin/thin.c
+++ b/lib/thin/thin.c
@@ -642,7 +642,7 @@ static int _thin_target_present(struct cmd_context *cmd,
 		uint32_t min;
 		unsigned thin_feature;
 		const char *feature;
-	} const _features[] = {
+	} _features[] = {
 		{ 1, 1, THIN_FEATURE_DISCARDS, "discards" },
 		{ 1, 1, THIN_FEATURE_EXTERNAL_ORIGIN, "external_origin" },
 		{ 1, 4, THIN_FEATURE_BLOCK_SIZE, "block_size" },


