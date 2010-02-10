From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 10 Feb 2010 15:55:41 +0100
Subject: [PATCH 2/6] Cleanup gcc const warning
In-Reply-To: <cover.1265812946.git.zkabelac@redhat.com>
References: <cover.1265812946.git.zkabelac@redhat.com>
Message-ID: <80c74b24ed1b9290086033a7fd60a783b0700bb6.1265812946.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/libdm-report.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 9925614..aead864 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -819,8 +819,8 @@ static int _report_headings(struct dm_report *rh)
  */
 static int _row_compare(const void *a, const void *b)
 {
-	const struct row *rowa = *(const struct row **) a;
-	const struct row *rowb = *(const struct row **) b;
+	const struct row *rowa = *(const struct row * const *) a;
+	const struct row *rowb = *(const struct row * const *) b;
 	const struct dm_report_field *sfa, *sfb;
 	uint32_t cnt;
 
-- 
1.6.6.1


