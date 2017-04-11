From: David Teigland <teigland@sourceware.org>
Date: Tue, 11 Apr 2017 11:40:58 -0400
Subject: master - lvconvert: validate vg name prefix for pool metadata name
Message-ID: <201704111540.v3BFewWe032384@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=2fd9ae070351dd2682d42aad3df5c9acec195bc0
Commit:        2fd9ae070351dd2682d42aad3df5c9acec195bc0
Parent:        21da004e58cdd406d5de0d67f27686373d7d2bfe
Author:        David Teigland <teigland@redhat.com>
AuthorDate:    Tue Apr 11 10:40:08 2017 -0500
Committer:     David Teigland <teigland@redhat.com>
CommitterDate: Tue Apr 11 10:40:08 2017 -0500

lvconvert: validate vg name prefix for pool metadata name

---
 tools/lvconvert.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/tools/lvconvert.c b/tools/lvconvert.c
index c28a75f..ee7fb8b 100644
--- a/tools/lvconvert.c
+++ b/tools/lvconvert.c
@@ -2750,6 +2750,11 @@ static int _lvconvert_to_pool(struct cmd_context *cmd,
 	 */
 
 	if ((pool_metadata_name = arg_str_value(cmd, poolmetadata_ARG, NULL))) {
+		if (!validate_lvname_param(cmd, &vg->name, &pool_metadata_name)) {
+			log_error("Metadata LV %s not found.", pool_metadata_name);
+			return 0;
+		}
+
 		if (!(metadata_lv = find_lv(vg, pool_metadata_name))) {
 			log_error("Unknown pool metadata LV %s.", pool_metadata_name);
 			return 0;


