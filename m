From: Tony Asleson <tasleson@redhat.com>
Date: Wed,  3 Oct 2012 11:51:31 -0500
Subject: [PATCH] liblvm2app: correctly return "data_percent" property for thin volumes
Message-ID: <1349283091-10449-1-git-send-email-tasleson@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Signed-off-by: Tony Asleson <tasleson@redhat.com>
---
 lib/report/properties.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/lib/report/properties.c b/lib/report/properties.c
index d2eac5e..677781a 100644
--- a/lib/report/properties.c
+++ b/lib/report/properties.c
@@ -104,7 +104,11 @@ static percent_t _data_percent(const struct logical_volume *lv)
 {
 	percent_t perc;
 
-	return lv_thin_pool_percent(lv, 0, &perc) ? perc : PERCENT_INVALID;
+	if ( lv_is_thin_pool(lv) ) {
+		return lv_thin_pool_percent(lv, 0, &perc) ? perc : PERCENT_INVALID;
+	} else {
+		return lv_thin_percent(lv, 0, &perc) ? perc : PERCENT_INVALID;
+	}
 }
 
 static percent_t _metadata_percent(const struct logical_volume *lv)
-- 
1.7.11.4


