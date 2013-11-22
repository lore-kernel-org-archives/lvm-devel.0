From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Fri, 22 Nov 2013 20:09:21 +0000 (UTC)
Subject: master - cleanup: simplify pv uuid display
Message-ID: <20131122200921.C6B1361097@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3e0fb102dece1a4d476496c3b6291e319b6305be
Commit:        3e0fb102dece1a4d476496c3b6291e319b6305be
Parent:        bea118a87cd6cf7c63ccaa0d75691de1f73602ab
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Nov 22 13:23:31 2013 +0100
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Fri Nov 22 21:00:55 2013 +0100

cleanup: simplify  pv uuid display

Shorter code with explicit type casting.
---
 lib/report/report.c |   15 +++++----------
 1 files changed, 5 insertions(+), 10 deletions(-)

diff --git a/lib/report/report.c b/lib/report/report.c
index 20eab4f..2d39cb0 100644
--- a/lib/report/report.c
+++ b/lib/report/report.c
@@ -728,18 +728,13 @@ static int _pvuuid_disp(struct dm_report *rh __attribute__((unused)), struct dm_
 		        const void *data, void *private __attribute__((unused)))
 {
 	const struct label *label = (const struct label *) data;
-	char *repstr = NULL;
+	const char *repstr = "";
 
-	if (!label->dev)
-		dm_report_field_set_value(field, "", NULL);
-	else {
-		if (!(repstr = id_format_and_copy(mem, label->dev->pvid)))
-			return_0;
-
-		dm_report_field_set_value(field, repstr, NULL);
-	}
+	if (label->dev &&
+	    !(repstr = id_format_and_copy(mem, (const struct id *) label->dev->pvid)))
+		return_0;
 
-	return 1;
+	return _field_set_value(field, repstr, NULL);
 }
 
 static int _pvmdas_disp(struct dm_report *rh, struct dm_pool *mem,


