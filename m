From: Milan Broz <mbroz@redhat.com>
Date: Sat, 06 Jun 2009 18:49:04 +0200
Subject: [PATCH] round read ahead change
Message-ID: <4A2A9E00.40408@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Round read_ahead more intelligently and print warning.

Round reah ahead at least to one page up.
Print warning instead of verbose message.
Fix printed page in KB, sector value is confusing.

[why we are rounding it to pagesize at all?
it is kernel who should optimize reads and align them to pages]

Signed-off-by: Milan Broz <mbroz@redhat.com>
---
 tools/lvchange.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/tools/lvchange.c b/tools/lvchange.c
index 10795e3..5abb6e5 100644
--- a/tools/lvchange.c
+++ b/tools/lvchange.c
@@ -370,9 +370,12 @@ static int lvchange_readahead(struct cmd_context *cmd,
 
 	if (read_ahead != DM_READ_AHEAD_AUTO &&
 	    read_ahead != DM_READ_AHEAD_NONE && read_ahead % pagesize) {
-		read_ahead = (read_ahead / pagesize) * pagesize;
-		log_verbose("Rounding down readahead to %u sectors, a multiple "
-			    "of page size %u.", read_ahead, pagesize);
+		if (read_ahead < pagesize)
+			read_ahead = pagesize;
+		else
+			read_ahead = (read_ahead / pagesize) * pagesize;
+		log_warn("WARNING: Overriding readahead to %u sectors, a multiple "
+			    "of %uK page size.", read_ahead, pagesize >> 1);
 	}
 
 	if (lv->read_ahead == read_ahead) {



