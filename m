From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 11 Dec 2009 17:13:04 +0100
Subject: [PATCH 2/3] Report unrecognised key instead of field
In-Reply-To: <cover.1260547761.git.zkabelac@redhat.com>
References: <cover.1260547761.git.zkabelac@redhat.com>
Message-ID: <f9f75a02738968e46744da1805c7322491f55ad3.1260547761.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/libdm-report.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 339213e..ecd3717 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -549,7 +549,7 @@ static int _parse_keys(struct dm_report *rh, const char *keys,
 		while (*we && *we != ',')
 			we++;
 		if (!_key_match(rh, ws, (size_t) (we - ws), report_type_only)) {
-			log_error("dm_report: Unrecognised field: %.*s",
+			log_error("dm_report: Unrecognised key: %.*s",
 				  (int) (we - ws), ws);
 			return 0;
 		}
-- 
1.6.5.3


