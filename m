From: Peter Rajnoha <prajnoha@sourceware.org>
Date: Wed, 17 Aug 2022 10:52:27 +0000 (GMT)
Subject: main - config: check for possible mempool errors in _out_line_fn
Message-ID: <20220817105227.6B6B83858D1E@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=ac2c78544fa60490f9506f4ea0cd7d74d2395b28
Commit:        ac2c78544fa60490f9506f4ea0cd7d74d2395b28
Parent:        8a23683a59835d967eff193bf1f82cc4ee5a6fdf
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Aug 17 12:51:42 2022 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Aug 17 12:52:02 2022 +0200

config: check for possible mempool errors in _out_line_fn

---
 lib/config/config.c | 12 +++++++++---
 1 file changed, 9 insertions(+), 3 deletions(-)

diff --git a/lib/config/config.c b/lib/config/config.c
index db8f3c2c1..230ec3225 100644
--- a/lib/config/config.c
+++ b/lib/config/config.c
@@ -1872,9 +1872,15 @@ static int _out_line_fn(const struct dm_config_node *cn, const char *line, void
 			p = line + space_prefix_len;
 
 			/* copy space_prefix, skip key and '=', copy value */
-			dm_pool_begin_object(out->mem, len);
-			dm_pool_grow_object(out->mem, line, space_prefix_len);
-			dm_pool_grow_object(out->mem, p + strcspn(p, "=") + 1, len + 1);
+			if (!dm_pool_begin_object(out->mem, len))
+				return_0;
+
+			if (!dm_pool_grow_object(out->mem, line, space_prefix_len) ||
+			    !dm_pool_grow_object(out->mem, p + strcspn(p, "=") + 1, len + 1)) {
+				dm_pool_abandon_object(out->mem);
+				return_0;
+			}
+
 			line = dm_pool_end_object(out->mem);
 		} else
 			line = strchr(line, '=') + 1;

