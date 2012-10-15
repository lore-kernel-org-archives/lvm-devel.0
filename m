From: Jonathan Brassow <jbrassow@redhat.com>
Date: Mon, 15 Oct 2012 10:28:17 -0500
Subject: [PATCH] cluser mirror: Allow VGs to be built on cluster mirrors
Message-ID: <1350314897.3094.3.camel@f16>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

cluser mirror:  Allow VGs to be built on cluster mirrors

While it is possible to create VGs on top of cluster mirrors,
it is currently worthless to do so because no LVs can be created.
This is not a limitation of 'locking_type = 1' LVM.  IOW, you can
happily stack a VG on top of a single machine LV of 'mirror'
segment type.

The disconnect comes because of the way 'ignore_suspended_devices'
is set.  That is, it is not set during lvcreate/lvremove when
running 'locking_type = 1' (i.e. single machine).  However, it is set
- every time - when 'locking_type = 3' and the activation is sent
through clvmd.

'ignore_suspended_devices' is meant to avoid reading any DM device
that is suspended.  However, a mirror device can block I/O for a couple
reasons.  The first is because it is suspended.  The second is because
it has a unaddressed device failure.  The first case would be already
addressed by the generic rejection of all DM devices that are suspended.
The second is not addressed at all by also rejecting mirror devices if
'ignore_suspended_devices' is set.  Therefore, this chunk of code is
pointless.  It also is the cause of not being able to use mirrors as
a source for VG stacking.

Index: lvm2/lib/activate/dev_manager.c
===================================================================
--- lvm2.orig/lib/activate/dev_manager.c
+++ lvm2/lib/activate/dev_manager.c
@@ -181,16 +181,10 @@ int device_is_usable(struct device *dev)
 	}
 
 	/* FIXME Also check for mirror block_on_error and mpath no paths */
-	/* For now, we exclude all mirrors */
-
 	do {
 		next = dm_get_next_target(dmt, next, &start, &length,
 					  &target_type, &params);
 		/* Skip if target type doesn't match */
-		if (target_type && !strcmp(target_type, "mirror") && ignore_suspended_devices()) {
-			log_debug("%s: Mirror device %s not usable.", dev_name(dev), name);
-			goto out;
-		}
 
 		/*
 		 * Snapshot origin could be sitting on top of a mirror which



