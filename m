From: Peter Rajnoha <prajnoha@fedoraproject.org>
Date: Thu, 31 Jul 2014 08:07:20 +0000 (UTC)
Subject: master - metadata: remove spurious "Physical volume <dev_name> not found"
Message-ID: <20140731080720.10E676032C@fedorahosted.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Gitweb:        http://git.fedorahosted.org/git/?p=lvm2.git;a=commitdiff;h=ef8599798069b2c49aa1c296e6f8b050458b6aeb
Commit:        ef8599798069b2c49aa1c296e6f8b050458b6aeb
Parent:        7cff640d9ae20a94647610e5adbb4151b7652fe5
Author:        Peter Rajnoha <prajnoha@redhat.com>
AuthorDate:    Thu Jul 31 09:30:25 2014 +0200
Committer:     Peter Rajnoha <prajnoha@redhat.com>
CommitterDate: Thu Jul 31 10:03:30 2014 +0200

metadata: remove spurious "Physical volume <dev_name> not found"

This is addendum to commit 2e82a070f3c9224da5c9f383d47e75a1715586cf
which fixed these spurious messages that appeared after commit
651d5093edde3e0ebee9d75be1c9834efc152d91 ("avoid pv_read in
find_pv_by_name").

There was one more "not found" message issued in case the device
could not be found in device cache (commit 2e82a07 fixed this only
for PV lookup itself). But if we "allow_unformatted" for
find_pv_by_name, we should not issue this message even in case
the device can't be found in dev cache as we just need to know
whether there's a PV or not for the code to decide on next steps
and we don't want to issue any messages if either device itself
is not found or PV is not found.

For example, when we were creating a new PV (and so allow_unformatted = 1)
and the device had a signature on it which caused it to be filtered
by device filter (e.g. MD signature if md filtering is enabled),
or it was part of some other subsystem (e.g. multipath), this message
was issued on find_pv_by_name call which was misleading.

Also, remove misleading "stack" call in case find_pv_by_name
returns NULL in pvcreate_check - any error state is reported
later by pvcreate_check code so no need to "stack" here.

There's one more and proper check to issue "not found" message if
the device can't be found in device cache within pvcreate_check fn
so this situation is still covered properly later in the code.

Before this patch (/dev/sda contains MD signature and is therefore filtered):

$ pvcreate /dev/sda
  Physical volume /dev/sda not found
WARNING: linux_raid_member signature detected on /dev/sda at offset 4096. Wipe it? [y/n]:

With this patch applied:

$ pvcreate /dev/sda
WARNING: linux_raid_member signature detected on /dev/sda at offset 4096. Wipe it? [y/n]:

Non-existent devices are still caught properly:

$ pvcreate /dev/sdx
  Device /dev/sdx not found (or ignored by filtering).
---
 WHATS_NEW               |    1 +
 lib/metadata/metadata.c |    7 ++++---
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/WHATS_NEW b/WHATS_NEW
index ace357b..03cf668 100644
--- a/WHATS_NEW
+++ b/WHATS_NEW
@@ -1,5 +1,6 @@
 Version 2.02.109 - 
 =================================
+  Remove possible spurious "not found" message on PV create before wiping.
   Handle upgrade from 2.02.105 when an LV now gaining a uuid suffix is active.
 
 Version 2.02.108 - 23rd July 2014
diff --git a/lib/metadata/metadata.c b/lib/metadata/metadata.c
index 0832750..39fa45f 100644
--- a/lib/metadata/metadata.c
+++ b/lib/metadata/metadata.c
@@ -685,8 +685,8 @@ static int vg_extend_single_pv(struct volume_group *vg, char *pv_name,
 {
 	struct physical_volume *pv;
 
-	if (!(pv = find_pv_by_name(vg->cmd, pv_name, 1, 1)))
-		stack;
+	pv = find_pv_by_name(vg->cmd, pv_name, 1, 1);
+
 	if (!pv && !pp) {
 		log_error("%s not identified as an existing "
 			  "physical volume", pv_name);
@@ -1858,7 +1858,8 @@ struct physical_volume *find_pv_by_name(struct cmd_context *cmd,
 	lvmcache_seed_infos_from_lvmetad(cmd);
 
 	if (!(dev = dev_cache_get(pv_name, cmd->filter))) {
-		log_error("Physical volume %s not found", pv_name);
+		if (!allow_unformatted)
+			log_error("Physical volume %s not found", pv_name);
 		return_NULL;
 	}
 


