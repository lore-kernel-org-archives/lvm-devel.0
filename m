From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Fri, 23 Apr 2021 21:05:58 +0000 (GMT)
Subject: main - cov: use correct enum type
Message-ID: <20210423210558.874D239450F9@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=25b672417e06265c4552184b4ae1f0853bd31732
Commit:        25b672417e06265c4552184b4ae1f0853bd31732
Parent:        395ce6c2bb034ed64479fcf4bc8974615a0f4bb8
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Thu Apr 22 17:31:17 2021 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Apr 23 23:00:55 2021 +0200

cov: use correct enum type

Correct function declaration.
---
 lib/format_text/import_vsn1.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/format_text/import_vsn1.c b/lib/format_text/import_vsn1.c
index ef25369a6..946184b4b 100644
--- a/lib/format_text/import_vsn1.c
+++ b/lib/format_text/import_vsn1.c
@@ -128,7 +128,7 @@ static int _read_id(struct id *id, const struct dm_config_node *cn, const char *
 	return 1;
 }
 
-static int _read_flag_config(const struct dm_config_node *n, uint64_t *status, int type)
+static int _read_flag_config(const struct dm_config_node *n, uint64_t *status, enum pv_vg_lv_e type)
 {
 	const struct dm_config_value *cv;
 	*status = 0;


