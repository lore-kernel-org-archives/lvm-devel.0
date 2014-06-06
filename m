From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  6 Jun 2014 12:02:49 +0000 (UTC)
Subject: dev-prajnoha-report-select - report: fix report field type for lv_kernel_major/minor
Message-ID: <20140606120249.4EEE760F1C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=03621692774e33357acc11ad23d4c8d1faffe971
Commit:        03621692774e33357acc11ad23d4c8d1faffe971
Parent:        442820aae3648e1846417d1248fa36030eba4bd8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri May 30 17:23:54 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri May 30 17:24:07 2014 +0200

report: fix report field type for lv_kernel_major/minor

Should be defined as numeric field, not string field.
---
 lib/report/columns.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index 93b5575..7c36d10 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -36,8 +36,8 @@ FIELD(LVS, lv, STR, "Active", lvid, 6, lvactive, lv_active, "Active state of the
 FIELD(LVS, lv, NUM, "Maj", major, 3, int32, lv_major, "Persistent major number or -1 if not persistent.", 0)
 FIELD(LVS, lv, NUM, "Min", minor, 3, int32, lv_minor, "Persistent minor number or -1 if not persistent.", 0)
 FIELD(LVS, lv, NUM, "Rahead", lvid, 6, lvreadahead, lv_read_ahead, "Read ahead setting in current units.", 0)
-FIELD(LVS, lv, STR, "KMaj", lvid, 4, lvkmaj, lv_kernel_major, "Currently assigned major number or -1 if LV is not active.", 0)
-FIELD(LVS, lv, STR, "KMin", lvid, 4, lvkmin, lv_kernel_minor, "Currently assigned minor number or -1 if LV is not active.", 0)
+FIELD(LVS, lv, NUM, "KMaj", lvid, 4, lvkmaj, lv_kernel_major, "Currently assigned major number or -1 if LV is not active.", 0)
+FIELD(LVS, lv, NUM, "KMin", lvid, 4, lvkmin, lv_kernel_minor, "Currently assigned minor number or -1 if LV is not active.", 0)
 FIELD(LVS, lv, NUM, "KRahead", lvid, 7, lvkreadahead, lv_kernel_read_ahead, "Currently-in-use read ahead setting in current units.", 0)
 FIELD(LVS, lv, NUM, "LSize", size, 5, size64, lv_size, "Size of LV in current units.", 0)
 FIELD(LVS, lv, NUM, "MSize", lvid, 6, lvmetadatasize, lv_metadata_size, "For thin pools, the size of the LV that holds the metadata.", 0)


