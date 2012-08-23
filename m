From: Zdenek Kabelac <zkabelac@fedoraproject.org>
Date: Thu, 23 Aug 2012 12:42:43 +0000 (UTC)
Subject: master - cleanup: cast to matching type
Message-ID: <20120823124243.768C2A0D9A@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=90191e6ff2d156abceebafa342ec34274b6bd22a
Commit:        90191e6ff2d156abceebafa342ec34274b6bd22a
Parent:        14d2b5a13ff6637f2ff1e8bd40dc8ca67e53e51b
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Fri Aug 17 12:15:36 2012 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Thu Aug 23 14:37:38 2012 +0200

cleanup: cast to matching type

---
 tools/dmsetup.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/tools/dmsetup.c b/tools/dmsetup.c
index 0734ded..0ac970f 100644
--- a/tools/dmsetup.c
+++ b/tools/dmsetup.c
@@ -2283,7 +2283,7 @@ static int _dm_mangled_name_disp(struct dm_report *rh,
 	int r = 0;
 
 	if ((name = dm_task_get_name_mangled((const struct dm_task *) data))) {
-		r = dm_report_field_string(rh, field, (const char **) &name);
+		r = dm_report_field_string(rh, field, (const char * const *) &name);
 		dm_free(name);
 	}
 
@@ -2299,7 +2299,7 @@ static int _dm_unmangled_name_disp(struct dm_report *rh,
 	int r = 0;
 
 	if ((name = dm_task_get_name_unmangled((const struct dm_task *) data))) {
-		r = dm_report_field_string(rh, field, (const char **) &name);
+		r = dm_report_field_string(rh, field, (const char * const *) &name);
 		dm_free(name);
 	}
 


