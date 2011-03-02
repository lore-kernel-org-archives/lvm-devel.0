From: zkabelac@sourceware.org <zkabelac@sourceware.org>
Date: 2 Mar 2011 08:41:55 -0000
Subject: LVM2/libdm/ioctl libdm-iface.c
Message-ID: <20110302084155.1691.qmail@sourceware.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

CVSROOT:	/cvs/lvm2
Module name:	LVM2
Changes by:	zkabelac at sourceware.org	2011-03-02 08:41:55

Modified files:
	libdm/ioctl    : libdm-iface.c 

Log message:
	Indent case part properly

Patches:
http://sourceware.org/cgi-bin/cvsweb.cgi/LVM2/libdm/ioctl/libdm-iface.c.diff?cvsroot=lvm2&r1=1.96&r2=1.97

--- LVM2/libdm/ioctl/libdm-iface.c	2011/03/02 00:29:57	1.96
+++ LVM2/libdm/ioctl/libdm-iface.c	2011/03/02 08:41:55	1.97
@@ -2111,8 +2111,8 @@
 
 	switch (dmt->type) {
 	case DM_DEVICE_CREATE:
-	    if ((dmt->add_node == DM_ADD_NODE_ON_CREATE) &&
-		dmt->dev_name && *dmt->dev_name && !udev_only)
+		if ((dmt->add_node == DM_ADD_NODE_ON_CREATE) &&
+		    dmt->dev_name && *dmt->dev_name && !udev_only)
 			add_dev_node(dmt->dev_name, MAJOR(dmi->dev),
 				     MINOR(dmi->dev), dmt->uid, dmt->gid,
 				     dmt->mode, check_udev);


