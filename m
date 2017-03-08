From: Heinz Mauelshagen <heinzm@sourceware.org>
Date: Wed, 8 Mar 2017 09:14:34 -0500
Subject: master - metadata: comments
Message-ID: <201703081414.v28EEYui022293@int-mx11.intmail.prod.int.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ed58672029567858709113b67337e4dfaf31d210
Commit:        ed58672029567858709113b67337e4dfaf31d210
Parent:        3a5561e5ab5c916df8f90cc880ce2acb04ee2ecb
Author:        Heinz Mauelshagen <heinzm@redhat.com>
AuthorDate:    Wed Mar 8 15:13:59 2017 +0100
Committer:     Heinz Mauelshagen <heinzm@redhat.com>
CommitterDate: Wed Mar 8 15:13:59 2017 +0100

metadata: comments

log_count,nosync,stripes,stripe_size,,...  are also used for raid.
---
 lib/metadata/metadata-exported.h |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/lib/metadata/metadata-exported.h b/lib/metadata/metadata-exported.h
index 4d02d04..4960499 100644
--- a/lib/metadata/metadata-exported.h
+++ b/lib/metadata/metadata-exported.h
@@ -916,8 +916,8 @@ struct lvcreate_params {
 	int wipe_signatures; /* all */
 	int32_t major; /* all */
 	int32_t minor; /* all */
-	int log_count; /* mirror */
-	int nosync; /* mirror */
+	int log_count; /* mirror/RAID */
+	int nosync; /* mirror/RAID */
 	int pool_metadata_spare; /* pools */
 	int type;   /* type arg is given */
 	int temporary; /* temporary LV */
@@ -948,15 +948,15 @@ struct lvcreate_params {
 #define PASS_ARG_ZERO			0x08
 	int passed_args;
 
-	uint32_t stripes; /* striped */
-	uint32_t stripe_size; /* striped */
+	uint32_t stripes; /* striped/RAID */
+	uint32_t stripe_size; /* striped/RAID */
 	uint32_t chunk_size; /* snapshot */
-	uint32_t region_size; /* mirror */
+	uint32_t region_size; /* mirror/RAID */
 
-	unsigned stripes_supplied; /* striped */
-	unsigned stripe_size_supplied; /* striped */
+	unsigned stripes_supplied; /* striped/RAID */
+	unsigned stripe_size_supplied; /* striped/RAID */
 
-	uint32_t mirrors; /* mirror */
+	uint32_t mirrors; /* mirror/RAID */
 
 	uint32_t min_recovery_rate; /* RAID */
 	uint32_t max_recovery_rate; /* RAID */


