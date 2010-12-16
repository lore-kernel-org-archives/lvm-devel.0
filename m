From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Thu, 16 Dec 2010 11:36:17 +0100
Subject: [PATCH 09/20] Replace stack trace with failure exit path
In-Reply-To: <cover.1292495195.git.zkabelac@redhat.com>
References: <cover.1292495195.git.zkabelac@redhat.com>
Message-ID: <9b6eb395e36beced8b714db6cc9ff5ac5cdf0dd6.1292495195.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

WARNING: functional change!

It looks like bug - an error return should be here
 - but the code currently ignores fail in engine construction
 - is there any use of rfilter without engine ?

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/filters/filter-regex.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/filters/filter-regex.c b/lib/filters/filter-regex.c
index d7c079e..e046c71 100644
--- a/lib/filters/filter-regex.c
+++ b/lib/filters/filter-regex.c
@@ -137,7 +137,7 @@ static int _build_matcher(struct rfilter *rf, const struct config_value *val)
 	 */
 	if (!(rf->engine = dm_regex_create(rf->mem, (const char **) regex,
 					   count)))
-		stack;
+		goto_out;
 	r = 1;
 
       out:
-- 
1.7.3.3


