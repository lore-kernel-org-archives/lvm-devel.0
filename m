From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Tue, 19 Aug 2014 14:18:49 +0000 (UTC)
Subject: master - lvscan: check result of id_write_format
Message-ID: <20140819141849.5CA4460DD2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=cdb16a603954a1a3771644a101d0b372f8e0826c
Commit:        cdb16a603954a1a3771644a101d0b372f8e0826c
Parent:        ad9aee9af46690032a0480ebd1023f400ea15841
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Tue Aug 19 14:26:06 2014 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Tue Aug 19 14:33:06 2014 +0200

lvscan: check result of id_write_format

Currently rather impossible to happen - but check
for returned value of id_write_format().
---
 tools/lvscan.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/tools/lvscan.c b/tools/lvscan.c
index 487c4cf..f05fd50 100644
--- a/tools/lvscan.c
+++ b/tools/lvscan.c
@@ -33,9 +33,11 @@ static int _lvscan_single_lvmetad(struct cmd_context *cmd, struct logical_volume
 
 	dm_list_iterate_items(pvl, &all_pvs) {
 		if (!pvl->pv->dev) {
-			id_write_format(&pvl->pv->id, pvid_s, sizeof(pvid_s));
-			log_warn("WARNING: Device for PV %s already missing, skipping.",
-				 pvid_s);
+			if (!id_write_format(&pvl->pv->id, pvid_s, sizeof(pvid_s)))
+				stack;
+			else
+				log_warn("WARNING: Device for PV %s already missing, skipping.",
+					 pvid_s);
 			continue;
 		}
 		if (!lvmetad_pvscan_single(cmd, pvl->pv->dev, NULL))


