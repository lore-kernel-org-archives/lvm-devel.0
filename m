From: Alasdair Kergon <agk@fedoraproject.org>
Date: Tue, 14 Jan 2014 03:48:46 +0000 (UTC)
Subject: master - format1: Mark obsolete and do not use with lvmetad.
Message-ID: <20140114034846.221EB610BA@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=3813cd7a3c3e763c346405664fba97edf7110d13
Commit:        3813cd7a3c3e763c346405664fba97edf7110d13
Parent:        5a450eab6a9fef7793066864ff58857d827b903f
Author:        Alasdair G Kergon <agk@redhat.com>
AuthorDate:    Tue Jan 14 03:27:45 2014 +0000
Committer:     Alasdair G Kergon <agk@redhat.com>
CommitterDate: Tue Jan 14 03:27:45 2014 +0000

format1: Mark obsolete and do not use with lvmetad.

DO NOT USE LVMETAD IF YOU HAVE ANY LVM1-FORMATTED PVS.

You may continue to use it without lvmetad, but do please schedule
an upgrade to the lvm2 format (with 'vgconvert').

Sending the original LVM1 formatted metadata to lvmetad is breaking
assumptions made by the code, so I am marking the format as obsolete for
now and no longer sending it to lvmetad.

This means that if you are using lvmetad, lvm1 volumes will usually
appear invisible - though not always: it depends on exactly what
sequence of commands you run!

The current situation is not satisfactory.

We'll either fix lvmetad and reenable this or we'll fix the code to
issue appropriate warning messages when lvm1 PVs are encountered
to avoid accidents.

(The latest unfixed problem is that lvmetad assumes metadata sequence
numbers exist and always increase - but the lvm1 format does not define
or store any sequence number, confusing both the daemon and client
when default values get passed to-and-fro.)
---
 WHATS_NEW             |    1 +
 lib/format1/format1.c |    2 +-
 2 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index 12845ab..834cf0f 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.105 -
 =====================================
+  Mark lvm1 format metadata as FMT_OBSOLETE. Do not use it with lvmetad.
   Invalidate cached VG struct after a PV in it gets orphaned. (2.02.87)
   Mark pool format metadata as FMT_OBSOLETE.
   Use major:minor in lvm2-pvscan at .service for proper global_filter application.
diff --git a/lib/format1/format1.c b/lib/format1/format1.c
index 509167a..16746e3 100644
--- a/lib/format1/format1.c
+++ b/lib/format1/format1.c
@@ -603,7 +603,7 @@ struct format_type *init_format(struct cmd_context *cmd)
 	fmt->alias = NULL;
 	fmt->orphan_vg_name = FMT_LVM1_ORPHAN_VG_NAME;
 	fmt->features = FMT_RESTRICTED_LVIDS | FMT_ORPHAN_ALLOCATABLE |
-			FMT_RESTRICTED_READAHEAD;
+			FMT_RESTRICTED_READAHEAD | FMT_OBSOLETE;
 	fmt->private = NULL;
 
 	dm_list_init(&fmt->mda_ops);


