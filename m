From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Fri,  5 Dec 2014 11:01:07 +0000 (UTC)
Subject: master - libdm: remove unimplemented dm_report_set_output_selection fn
Message-ID: <20141205110107.D82E160C2D@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=44394cd246dceec20dd404e3d39ba5867176d54b
Commit:        44394cd246dceec20dd404e3d39ba5867176d54b
Parent:        a5baf13a06fc509833803ee4c778bdf9b7f07399
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Fri Dec 5 11:38:51 2014 +0100
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Fri Dec 5 11:54:25 2014 +0100

libdm: remove unimplemented dm_report_set_output_selection fn

The dm_report_set_output_selection was not implemented in the end -
we have dm_report_init_with_selection instead. This is just a remnant
from development code that got into libdevmapper.h by mistake.
---
 WHATS_NEW_DM         |    1 +
 libdm/libdevmapper.h |    2 --
 2 files changed, 1 insertions(+), 2 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 8d1f648..98b0a5c 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.93 -
 ====================================
+  Remove unimplemented dm_report_set_output_selection from libdevmapper.h.
 
 Version 1.02.92 - 24th November 2014
 ====================================
diff --git a/libdm/libdevmapper.h b/libdm/libdevmapper.h
index 895ad48..3c93dfd 100644
--- a/libdm/libdevmapper.h
+++ b/libdm/libdevmapper.h
@@ -1753,8 +1753,6 @@ struct dm_report *dm_report_init_with_selection(uint32_t *report_types,
 						const struct dm_report_reserved_value reserved_values[],
 						void *private_data);
 int dm_report_object(struct dm_report *rh, void *object);
-int dm_report_set_output_selection(struct dm_report *rh, uint32_t *report_types,
-				   const char *selection);
 int dm_report_output(struct dm_report *rh);
 void dm_report_free(struct dm_report *rh);
 


