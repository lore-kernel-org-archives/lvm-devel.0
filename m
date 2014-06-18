From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Wed, 18 Jun 2014 10:34:14 +0000 (UTC)
Subject: master - WHATS_NEW: commit 76467bdcfd297ffbe2c088b6340ecc7d17d56742
Message-ID: <20140618103414.1AD7760C90@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ca1abe70ff6f6efc6bd49c648aa3e6b8fab184fd
Commit:        ca1abe70ff6f6efc6bd49c648aa3e6b8fab184fd
Parent:        63f5be01702f3344fe2e95eea74c5149bab2d78d
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Wed Jun 18 12:30:34 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Wed Jun 18 12:30:34 2014 +0200

WHATS_NEW: commit 76467bdcfd297ffbe2c088b6340ecc7d17d56742

Ordering string list items on reports is also new compared to
previous state where items were not ordered at all and they
got reported simply as they appeared/were processed.
---
 WHATS_NEW_DM |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index d1b05cb..9e6f92e 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -7,6 +7,7 @@ Version 1.02.88 -
   Add dm_report_reserved_value to libdevmapper for reserved value definition.
   Also display field types when listing all fields in selection help.
   Recognize "help" keyword in selection string to show brief help for selection.
+  Always order items reported as string list field lexicographically.
   Add dm_report_field_string_list to libdevmapper for direct string list report.
   Add DM_REPORT_FIELD_TYPE_STRING_LIST: separate string and string list fields.
   Add dm_str_list to libdevmapper for string list type definition and its reuse.


