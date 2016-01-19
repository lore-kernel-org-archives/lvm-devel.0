From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Tue, 19 Jan 2016 13:30:47 +0000 (UTC)
Subject: master - report: add note about seg_pe_ranges and seg_le_ranges in -o help
Message-ID: <20160119133047.80AAA6033B@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=acf1e84e8c067de246fd83b05e723049c9f91407
Commit:        acf1e84e8c067de246fd83b05e723049c9f91407
Parent:        1341f835547ce89240754054614ec5acea60a58a
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Tue Jan 19 13:53:30 2016 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Tue Jan 19 14:30:21 2016 +0100

report: add note about seg_pe_ranges and seg_le_ranges in -o help

---
 lib/report/columns.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/report/columns.h b/lib/report/columns.h
index bbea697..adc2d62 100644
--- a/lib/report/columns.h
+++ b/lib/report/columns.h
@@ -192,7 +192,7 @@ FIELD(SEGS, seg, NUM, "Start", list, 5, segstartpe, seg_start_pe, "Offset within
 FIELD(SEGS, seg, SIZ, "SSize", list, 5, segsize, seg_size, "Size of segment in current units.", 0)
 FIELD(SEGS, seg, SIZ, "SSize", list, 5, segsizepe, seg_size_pe, "Size of segment in physical extents.", 0)
 FIELD(SEGS, seg, STR_LIST, "Seg Tags", tags, 8, tags, seg_tags, "Tags, if any.", 0)
-FIELD(SEGS, seg, STR_LIST, "PE Ranges", list, 9, peranges, seg_pe_ranges, "Ranges of Physical Extents of underlying devices in command line format.", 0)
+FIELD(SEGS, seg, STR_LIST, "PE Ranges", list, 9, peranges, seg_pe_ranges, "Ranges of Physical Extents of underlying devices in command line format (deprecated, use seg_le_ranges for common format).", 0)
 FIELD(SEGS, seg, STR_LIST, "LE Ranges", list, 9, leranges, seg_le_ranges, "Ranges of Logical Extents of underlying devices in command line format.", 0)
 FIELD(SEGS, seg, STR_LIST, "Metadata LE Ranges", list, 18, metadataleranges, seg_metadata_le_ranges, "Ranges of Logical Extents of underlying metadata devices in command line format.", 0)
 FIELD(SEGS, seg, STR_LIST, "Devices", list, 7, devices, devices, "Underlying devices used with starting extent numbers.", 0)


