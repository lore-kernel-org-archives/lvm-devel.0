From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 30 Jan 2008 20:46:10 -0500
Subject: [PATCH] Add a debug message for tree-based deactivation
Message-ID: <47A12862.1030205@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

dm_tree_deactivate_children() of libdevmapper is a function
to walk down the dm deptree and deactivate each child
(i.e. remove dm device).

Since a dm device with open count > 0 can't be removed, it checks
info.open_count before the removal.
info.open_count > 0 is valid if the device is shared from other parent.

However, even if it's not shared, the open count can be non 0 if
something temporarily opens the device, for example.
Printing the reason why it was not deactivated makes it easier
to check whether the deptree was not correctly built or such
access happened.

The debug output will look like this:
(in this case, vg-lvol0_mimage_0 and 1 had non-zero open count
 and were not removed after the deactivation of the tree)

#ioctl/libdm-iface.c:1606         dm info   (253:14) OF   [16384]
#libdm-deptree.c:830     Removing vg-lvol0 (253:14)
#ioctl/libdm-iface.c:1606         dm remove   (253:14) NF   [16384]
#ioctl/libdm-iface.c:1606         dm info   (253:16) OF   [16384]
#libdm-deptree.c:830     Removing vg-lvol0_mimage_2 (253:16)
#ioctl/libdm-iface.c:1606         dm remove   (253:16) NF   [16384]
#ioctl/libdm-iface.c:1606         dm info   (253:15) OF   [16384]
#libdm-deptree.c:830     Removing vg-lvol0_mimagetmp_2 (253:15)
#ioctl/libdm-iface.c:1606         dm remove   (253:15) NF   [16384]
#ioctl/libdm-iface.c:1606         dm info   (253:13) OF   [16384]
#libdm-deptree.c:1009         vg-lvol0_mimage_1 (253:13) has open count 1
#ioctl/libdm-iface.c:1606         dm info   (253:12) OF   [16384]
#libdm-deptree.c:1009         vg-lvol0_mimage_0 (253:12) has open count 1
#ioctl/libdm-iface.c:1606         dm info   (253:4) OF   [16384]
#libdm-deptree.c:830     Removing vg-lvol0_mlog (253:4)
#ioctl/libdm-iface.c:1606         dm remove   (253:4) NF   [16384]

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: deptree-refcount-debug.patch
Type: text/x-patch
Size: 1405 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080130/8a43159c/attachment.bin>
