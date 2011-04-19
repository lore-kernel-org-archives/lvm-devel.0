From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 19 Apr 2011 14:55:27 +0200
Subject: [PATCH 4/5] Ignore dm_snprintf result
In-Reply-To: <cover.1303215346.git.zkabelac@redhat.com>
References: <cover.1303215346.git.zkabelac@redhat.com>
Message-ID: <e2439d9e1eea58fdcd8eb5b31be1b0a887ab9d07.1303215346.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/log/log.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/log/log.c b/lib/log/log.c
index ff98cdd..96ac474 100644
--- a/lib/log/log.c
+++ b/lib/log/log.c
@@ -275,8 +275,8 @@ void print_log(int level, const char *file, int line, int dm_errno,
       log_it:
 	if (!_log_suppress) {
 		if (verbose_level() > _LOG_DEBUG)
-			dm_snprintf(locn, sizeof(locn), "#%s:%d ",
-				     file, line);
+			(void) dm_snprintf(locn, sizeof(locn), "#%s:%d ",
+					   file, line);
 		else
 			locn[0] = '\0';
 
-- 
1.7.4.4


