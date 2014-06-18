From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 18 Jun 2014 11:30:48 +0000 (UTC)
Subject: master - cleanup: gcc warnings and report-select test vs snap_percent 0%
Message-ID: <20140618113048.A36B260E13@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=0548a82e630dc0bf24943ec49a15b86834268b57
Commit:        0548a82e630dc0bf24943ec49a15b86834268b57
Parent:        ca1abe70ff6f6efc6bd49c648aa3e6b8fab184fd
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 18 13:26:47 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 18 13:26:47 2014 +0200

cleanup: gcc warnings and report-select test vs snap_percent 0%

Fix gcc warnings:
libdm-report.c:1952:5: warning: "end_op_flag_hit" may be used uninitialized in this function [-Wmaybe-uninitialized]
libdm-report.c:2232:28: warning: "custom" may be used uninitialized in this function [-Wmaybe-uninitialized]

And snap_percent is not 0% in dm < 1.10.0 so
don't test comparison with 0% here.
---
 libdm/libdm-report.c        |    4 ++--
 test/shell/report-select.sh |    6 +++++-
 2 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/libdm/libdm-report.c b/libdm/libdm-report.c
index 79b3687..867bf44 100644
--- a/libdm/libdm-report.c
+++ b/libdm/libdm-report.c
@@ -1879,7 +1879,7 @@ static const char *_tok_value_string_list(const struct dm_report_field_type *ft,
 	struct selection_str_list *ssl = NULL;
 	struct dm_str_list *item;
 	const char *begin_item, *end_item, *tmp;
-	uint32_t end_op_flags, end_op_flag_hit;
+	uint32_t end_op_flags, end_op_flag_hit = 0;
 	struct dm_str_list **arr;
 	size_t list_size;
 	unsigned int i;
@@ -2400,7 +2400,7 @@ static struct selection_node *_parse_selection(struct dm_report *rh,
 	struct selection_str_list *str_list;
 	const struct dm_report_reserved_value *reserved;
 	uint64_t factor;
-	void *custom;
+	void *custom = NULL;
 	char *tmp;
 	char c;
 
diff --git a/test/shell/report-select.sh b/test/shell/report-select.sh
index 8df1d27..8181cd2 100644
--- a/test/shell/report-select.sh
+++ b/test/shell/report-select.sh
@@ -150,7 +150,11 @@ lvs_sel 'size<=8m' "vol2 xyz vol1 orig snap"
 ###########################
 # PERCENT FIELD SELECTION #
 ###########################
-lvs_sel 'snap_percent=0' "snap"
+if aux target_at_least dm-snapshot 1 10 0; then
+	# Test zero percent only if snapshot can be zero.
+	# Before 1.10.0, the snap percent included metadata size.
+	lvs_sel 'snap_percent=0' "snap"
+fi
 dd if=/dev/zero of=$DM_DEV_DIR/$vg3/snap bs=1M count=1
 lvs_sel 'snap_percent<50' "snap"
 lvs_sel 'snap_percent>50'


