From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Mon, 30 Jun 2014 08:57:23 +0000 (UTC)
Subject: master - libdm: fix double const for "value" in dm_report_reserved_value structure
Message-ID: <20140630085723.2A1DA6025C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=100342605ce4a304b397665682d2ec555af5aa27
Commit:        100342605ce4a304b397665682d2ec555af5aa27
Parent:        b41aa985d7f93ba9e2db6fab032e0cf3d7180cf8
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Mon Jun 30 09:44:23 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Mon Jun 30 09:44:23 2014 +0200

libdm: fix double const for "value" in dm_report_reserved_value structure

C++ may have
---
 libdm/libdevmapper.h |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 90e0b51..ad504da 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1660,7 +1660,7 @@ struct dm_report_field_type {
 
 struct dm_report_reserved_value {
 	const unsigned type;		/* DM_REPORT_FIELD_TYPE_* */
-	const void const *value;	/* reserved value:
+	const void *value;		/* reserved value:
 						uint64_t for DM_REPORT_FIELD_TYPE_NUMBER
 						uint64_t for DM_REPORT_FIELD_TYPE_SIZE (number of 512-byte sectors)
 						uint64_t for DM_REPORT_FIELD_TYPE_PERCENT


