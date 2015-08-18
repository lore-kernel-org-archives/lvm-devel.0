From: Bryn Reeves <bmr@fedoraproject.org>
Date: Tue, 18 Aug 2015 09:31:55 +0000 (UTC)
Subject: master - dmstats: fix type formatting
Message-ID: <20150818093155.B3F8C60DBF@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=13d3eeb2ee687455bd6e19ff6dae314b3a85776a
Commit:        13d3eeb2ee687455bd6e19ff6dae314b3a85776a
Parent:        dece918bc8e0d4e3222c4e71fc7f212b994e358c
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Aug 17 17:30:38 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Tue Aug 18 10:30:53 2015 +0100

dmstats: fix type formatting

Fix several instances of 'const char * const*' to be:

  'const char * const *'
---
 tools/dmsetup.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index a937027..10ec7a5 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -3409,7 +3409,7 @@ static int _dm_stats_program_id_disp(struct dm_report *rh,
 	const char *program_id;
 	if (!(program_id = dm_stats_get_current_region_program_id(dms)))
 		return_0;
-	return dm_report_field_string(rh, field, (const char * const*) &program_id);
+	return dm_report_field_string(rh, field, (const char * const *) &program_id);
 }
 
 static int _dm_stats_aux_data_disp(struct dm_report *rh,
@@ -3421,7 +3421,7 @@ static int _dm_stats_aux_data_disp(struct dm_report *rh,
 	const char *aux_data;
 	if (!(aux_data = dm_stats_get_current_region_aux_data(dms)))
 		return_0;
-	return dm_report_field_string(rh, field, (const char * const*) &aux_data);
+	return dm_report_field_string(rh, field, (const char * const *) &aux_data);
 }
 
 static int _dm_stats_rrqm_disp(struct dm_report *rh,


