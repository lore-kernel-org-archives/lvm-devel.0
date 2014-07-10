From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 10 Jul 2014 11:42:25 +0000 (UTC)
Subject: master - report: reserved value: description for undefined value
Message-ID: <20140710114225.3F2F5614B9@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=e31ec38d8e657d5f6d6efca6eade083357675276
Commit:        e31ec38d8e657d5f6d6efca6eade083357675276
Parent:        175de52deddbd0727c42d7a3e34d27b6f70f2deb
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 10 13:42:16 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jul 10 13:42:16 2014 +0200

report: reserved value: description for undefined value

---
 lib/report/values.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/lib/report/values.h b/lib/report/values.h
index 3ee6192..d8de665 100644
--- a/lib/report/values.h
+++ b/lib/report/values.h
@@ -42,7 +42,7 @@
 /* *INDENT-OFF* */
 
 /* Per-type reserved values usable for all fields of certain type. */
-TYPE_RESERVED_VALUE(NUM, number_undef_64, "", UINT64_C(-1), "-1", "unknown", "undefined", "undef")
+TYPE_RESERVED_VALUE(NUM, number_undef_64, "Reserved value for undefined numeric value.", UINT64_C(-1), "-1", "unknown", "undefined", "undef")
 
 /* Reserved values for PV fields */
 FIELD_RESERVED_BINARY_VALUE(pv_allocatable, pv_allocatable, "", "allocatable")


