From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon,  3 Aug 2015 14:47:14 +0000 (UTC)
Subject: master - report: update comment for _is_same_field fn
Message-ID: <20150803144714.415A4602BB@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=71dbe47619794ed673a892f533c348a472411195
Commit:        71dbe47619794ed673a892f533c348a472411195
Parent:        a5b476a7d3ffd06fa8124395857b4dcca32d612b
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Aug 3 16:47:02 2015 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Aug 3 16:47:02 2015 +0200

report: update comment for _is_same_field fn

---
 libdm/libdm-report.c |    7 ++++---
 1 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 64ba033..5b94311 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -845,9 +845,10 @@ static int _get_canonical_field_name(const char *field,
 }
 
 /*
- * Compare name1 against name2 or prefix plus name2
- * name2 is not necessarily null-terminated.
- * len2 is the length of name2.
+ * Compare canonical_name1 against canonical_name2 or prefix
+ * plus canonical_name2. Canonical name is a name where all
+ * superfluous characters are removed (underscores for now).
+ * Both names are always null-terminated.
  */
 static int _is_same_field(const char *canonical_name1, const char *canonical_name2,
 			  const char *prefix)


