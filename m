From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 10 Feb 2010 15:55:43 +0100
Subject: [PATCH 4/6] Cleanup float arithmetic gcc warning
In-Reply-To: <cover.1265812946.git.zkabelac@redhat.com>
References: <cover.1265812946.git.zkabelac@redhat.com>
Message-ID: <a4b47d75120fbb181db5586bd0809763b457f86d.1265812946.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit


Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 lib/report/report.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index cf037cb..e27f4e1 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -1055,7 +1055,7 @@ static int _snpercent_disp(struct dm_report *rh __attribute((unused)), struct dm
 		return 0;
 	}
 
-	*sortval = snap_percent * UINT64_C(1000);
+	*sortval = (uint64_t)(snap_percent * 1000.f);
 	dm_report_field_set_value(field, repstr, sortval);
 
 	return 1;
@@ -1097,7 +1097,7 @@ static int _copypercent_disp(struct dm_report *rh __attribute((unused)),
 		return 0;
 	}
 
-	*sortval = percent * UINT64_C(1000);
+	*sortval = (uint64_t)(percent * 1000.f);
 	dm_report_field_set_value(field, repstr, sortval);
 
 	return 1;
-- 
1.6.6.1


