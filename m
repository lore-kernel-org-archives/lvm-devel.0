From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 15 Feb 2016 12:08:51 +0000 (UTC)
Subject: master - report: identify used PVs in pv_attr field with 'u' char
Message-ID: <20160215120851.0BCBB60A9E@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=08de88535e4b06906507abf7ab79bf26be6469f8
Commit:        08de88535e4b06906507abf7ab79bf26be6469f8
Parent:        db494d7d344f323c7255d6ceb9cd5180e4b6f23b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Feb 11 15:34:05 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Feb 15 12:44:46 2016 +0100

report: identify used PVs in pv_attr field with 'u' char

---
 lib/metadata/pv.c |    4 +++-
 man/pvs.8.in      |    3 ++-
 2 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/lib/metadata/pv.c b/lib/metadata/pv.c
index 7ea7d2b..260eb9b 100644
--- a/lib/metadata/pv.c
+++ b/lib/metadata/pv.c
@@ -232,8 +232,9 @@ int is_used_pv(const struct physical_volume *pv)
 char *pv_attr_dup(struct dm_pool *mem, const struct physical_volume *pv)
 {
 	char *repstr;
+	int used = is_used_pv(pv);
 
-	if (!(repstr = dm_pool_zalloc(mem, 4))) {
+	if (!(repstr = dm_pool_zalloc(mem, 5))) {
 		log_error("dm_pool_alloc failed");
 		return NULL;
 	}
@@ -241,6 +242,7 @@ char *pv_attr_dup(struct dm_pool *mem, const struct physical_volume *pv)
 	repstr[0] = (pv->status & ALLOCATABLE_PV) ? 'a' : '-';
 	repstr[1] = (pv->status & EXPORTED_VG) ? 'x' : '-';
 	repstr[2] = (pv->status & MISSING_PV) ? 'm' : '-';
+	repstr[3] = used <= 0 ? '-' : 'u';
 
 	return repstr;
 }
diff --git a/man/pvs.8.in b/man/pvs.8.in
index efafbde..4bc042b 100644
--- a/man/pvs.8.in
+++ b/man/pvs.8.in
@@ -85,7 +85,8 @@ pv_mda_used_count, pvseg_start, and pvseg_size
 .IP
 With \fB\-\-segments\fP, any "pvseg_" prefixes are optional; otherwise any
 "pv_" prefixes are optional.  Columns mentioned in \fBvgs\fP(8) can also
-be chosen. The pv_attr bits are: (a)llocatable, e(x)ported and (m)issing.
+be chosen. The pv_attr bits are: @llocatable, e(x)ported, (m)issing and
+(u)sed.
 .TP
 .B \-\-segments
 Produces one line of output for each contiguous allocation of space on each


