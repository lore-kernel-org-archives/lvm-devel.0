From: Zdenek Kabelac <zkabelac@sourceware.org>
Date: Mon, 26 Jun 2017 14:08:26 -0400
Subject: master - libdm: fix initialization of head for reused structure
Message-ID: <201706261808.v5QI8QmB008701@lists01.pubmisc.prod.ext.phx2.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        https://sourceware.org/git/?p=lvm2.git;a=commitdiff;h=4e4067dd94f52f90f0aaae30c522102ccbaa2826
Commit:        4e4067dd94f52f90f0aaae30c522102ccbaa2826
Parent:        0cc49bda15c041dc6e53b17a10b9306abd7d1a93
Author:        Zdenek Kabelac <zkabelac@redhat.com>
AuthorDate:    Mon Jun 26 18:22:40 2017 +0200
Committer:     Zdenek Kabelac <zkabelac@redhat.com>
CommitterDate: Mon Jun 26 19:45:11 2017 +0200

libdm: fix initialization of head for reused structure

Dmeventd reuses  'dm_task' struct for some STATUS operation, but due to
missing reinitization of dm_task target list, it has caused misprocesing
of recieved events as the parsed target has been simply added to the
list of existing status and cause multiple actions being called for
single event.
---
 WHATS_NEW_DM              |    1 +
 libdm/ioctl/libdm-iface.c |   10 +++++++++-
 2 files changed, 10 insertions(+), 1 deletions(-)

diff --git a/WHATS_NEW_DM b/WHATS_NEW_DM
index 89f4a00..2e31b9a 100644
--- a/WHATS_NEW_DM
+++ b/WHATS_NEW_DM
@@ -1,5 +1,6 @@
 Version 1.02.141 - 
 ===============================
+  Fix reusing of dm_task structure for status reading (used by dmeventd).
   Add dm_percent_to_round_float for adjusted percentage rounding.
   Reset array with dead rimage devices once raid gets in sync.
   Drop unneeded --config option from raid dmeventd plugin.
diff --git a/libdm/ioctl/libdm-iface.c b/libdm/ioctl/libdm-iface.c
index cb3e8dc..65e75f6 100644
--- a/libdm/ioctl/libdm-iface.c
+++ b/libdm/ioctl/libdm-iface.c
@@ -467,7 +467,7 @@ static void _dm_zfree_dmi(struct dm_ioctl *dmi)
 	}
 }
 
-void dm_task_destroy(struct dm_task *dmt)
+static void _dm_task_free_targets(struct dm_task *dmt)
 {
 	struct target *t, *n;
 
@@ -478,6 +478,12 @@ void dm_task_destroy(struct dm_task *dmt)
 		dm_free(t);
 	}
 
+	dmt->head = dmt->tail = NULL;
+}
+
+void dm_task_destroy(struct dm_task *dmt)
+{
+	_dm_task_free_targets(dmt);
 	_dm_zfree_dmi(dmt->dmi.v4);
 	dm_free(dmt->dev_name);
 	dm_free(dmt->mangled_dev_name);
@@ -652,6 +658,8 @@ static int _unmarshal_status(struct dm_task *dmt, struct dm_ioctl *dmi)
 	uint32_t i;
 	struct dm_target_spec *spec;
 
+	_dm_task_free_targets(dmt);
+
 	for (i = 0; i < dmi->target_count; i++) {
 		spec = (struct dm_target_spec *) outptr;
 		if (!dm_task_add_target(dmt, spec->sector_start,


