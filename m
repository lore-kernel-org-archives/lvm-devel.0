From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 29 Jun 2010 18:26:01 +0200
Subject: [PATCH 01/12] Allow the user to not specify a size when creating snapshot.
In-Reply-To: <cover.1277828149.git.zkabelac@redhat.com>
References: <cover.1277828149.git.zkabelac@redhat.com>
Message-ID: <b100d71fa95ce566dc24c79a56deace4c166d583.1277828149.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

For shared snapshot, the size is not required. If the user creates other
volume than a shared snapshot, zero size will be rejected in
lv_create_single.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>
Reviewed-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 tools/lvcreate.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/tools/lvcreate.c b/tools/lvcreate.c
index d0e962f..9e167aa 100644
--- a/tools/lvcreate.c
+++ b/tools/lvcreate.c
@@ -191,6 +191,9 @@ static int _read_size_params(struct lvcreate_params *lp,
 			     struct lvcreate_cmdline_params *lcp,
 			     struct cmd_context *cmd)
 {
+	if (!arg_count(cmd, extents_ARG) && !arg_count(cmd, size_ARG))
+		goto skip_size_arg;
+
 	if (arg_count(cmd, extents_ARG) + arg_count(cmd, size_ARG) != 1) {
 		log_error("Please specify either size or extents (not both)");
 		return 0;
@@ -215,6 +218,7 @@ static int _read_size_params(struct lvcreate_params *lp,
 		lcp->percent = PERCENT_NONE;
 	}
 
+skip_size_arg:
 	/* Size returned in kilobyte units; held in sectors */
 	if (arg_count(cmd, virtualsize_ARG)) {
 		if (arg_sign_value(cmd, virtualsize_ARG, 0) == SIGN_MINUS) {
-- 
1.7.1


