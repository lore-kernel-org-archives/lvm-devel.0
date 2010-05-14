From: Milan Broz <mbroz@redhat.com>
Date: Fri, 14 May 2010 11:00:58 +0200
Subject: LVM2 ./WHATS_NEW lib/activate/activate.h lib/a ...
In-Reply-To: <20100513234711.GP2377@agk-dp.fab.redhat.com>
References: <20100513183841.1542.qmail@sourceware.org>
	<20100513234711.GP2377@agk-dp.fab.redhat.com>
Message-ID: <4BED114A.1090507@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On 05/14/2010 01:47 AM, Alasdair G Kergon wrote:
> Mixing up types there.
> name is a dm device name
>
>   
yep. ok with that patch? (we have no mempool available there, that's why
dm_strdup)

diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
index 710b3ae..d01bd63 100644
--- a/lib/activate/dev_manager.c
+++ b/lib/activate/dev_manager.c
@@ -133,7 +133,7 @@ int device_is_usable(struct device *dev)
 	const char *name, *uuid;
 	uint64_t start, length;
 	char *target_type = NULL;
-	char *params;
+	char *params, *vgname = NULL, *lvname, *layer;
 	void *next = NULL;
 	int r = 0;
 
@@ -175,15 +175,23 @@ int device_is_usable(struct device *dev)
 	/* FIXME Also check dependencies? */
 
 	/* Check internal lvm devices */
-	if (is_reserved_lvname(name) && uuid &&
-	    !strncmp(uuid, UUID_PREFIX, sizeof(UUID_PREFIX) - 1)) {
-		log_debug("%s: Reserved internal LVM device not usable.", dev_name(dev));
-		goto out;
+	if (uuid && !strncmp(uuid, UUID_PREFIX, sizeof(UUID_PREFIX) - 1)) {
+		if (!(vgname = dm_strdup(name)) ||
+		    !dm_split_lvm_name(NULL, NULL, &vgname, &lvname, &layer))
+			goto_out;
+
+		if (lvname && is_reserved_lvname(lvname)) {
+			log_debug("%s: Reserved internal LV device %s/%s not usable.",
+				  dev_name(dev), vgname, lvname);
+			goto out;
+		}
 	}
 
 	r = 1;
 
       out:
+	if (vgname)
+		dm_free(vgname);
 	dm_task_destroy(dmt);
 	return r;
 }



