From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 11 Dec 2009 17:13:02 +0100
Subject: [PATCH 1/3] Fix reporting dmsetup info -c -o all
In-Reply-To: <cover.1260547761.git.zkabelac@redhat.com>
References: <cover.1260547761.git.zkabelac@redhat.com>
Message-ID: <e5b04bbd53a48c1323977411eef561b191670bb2.1260547761.git.zkabelac@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Use whole bitmask of all options.

Signed-off-by: Zdenek Kabelac <zkabelac@redhat.com>
---
 libdm/libdm-report.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 6784a11..339213e 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -379,7 +379,9 @@ static uint32_t _all_match(struct dm_report *rh, const char *field, size_t flen)
 			       _all_match(rh, prefixed_all,
 					  strlen(prefixed_all));
 		} else
-			return rh->report_types;
+			/* all without type use full bitmask */
+			return (!rh->report_types)
+				? UINT_MAX : rh->report_types;
 	}
 
 	for (t = rh->types; t->data_fn; t++) {
-- 
1.6.5.3


