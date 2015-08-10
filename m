From: Bryn Reeves <bmr@fedoraproject.org>
Date: Mon, 10 Aug 2015 19:30:25 +0000 (UTC)
Subject: master - libdm: fix FILE leak in _program_id_from_proc() (Coverity)
Message-ID: <20150810193025.674A360DE2@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=1134de3c89c5a07699365031d0cb88383e365929
Commit:        1134de3c89c5a07699365031d0cb88383e365929
Parent:        3b74824985f7e4e90f0ba9668724abd08d5fef74
Author:        Bryn M. Reeves <bmr@redhat.com>
AuthorDate:    Mon Aug 10 10:08:03 2015 +0100
Committer:     Bryn M. Reeves <bmr@redhat.com>
CommitterDate: Mon Aug 10 20:20:26 2015 +0100

libdm: fix FILE leak in _program_id_from_proc() (Coverity)

Make sure comm is closed in the error path of _program_id_from_proc().

libdm/libdm-stats.c: 98 in dm_stats_create() - Variable "comm" going out of scope leaks the storage it points to.
---
 libdm/libdm-stats.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/libdm/libdm-stats.c b/libdm/libdm-stats.c
index bf3cad0..64ca23f 100644
--- a/libdm/libdm-stats.c
+++ b/libdm/libdm-stats.c
@@ -79,11 +79,13 @@ static char *_program_id_from_proc(void)
 	if (!(comm = fopen(PROC_SELF_COMM, "r")))
 		return_NULL;
 
-	if (!fgets(buf, sizeof(buf), comm))
-		return_NULL;
+	if (!fgets(buf, sizeof(buf), comm)) {
+		log_error("Could not read from %s", PROC_SELF_COMM);
+		fclose(comm);
+		return NULL;
+	}
 
-	if (fclose(comm))
-		return_NULL;
+	fclose(comm);
 
 	return dm_strdup(buf);
 }


