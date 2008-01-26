From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Fri, 25 Jan 2008 19:13:06 -0500
Subject: 'Resuming before suspend' problem
Message-ID: <479A7B12.3060200@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi,

Attached is a patch to workaround the problem that resuming
of a inserted layer occurs before the suspending of the
original mirror.

I would like to hear comments about how to fix this problem:

Current status:
  - suspend_lv() in LVM2 preloads dm tables before suspending.
    It's necessary because the table loading could require memory
    while kernel may not able to allocate memory without writing
    to the device.
  - The preloading involves resuming, if the device has a parent
    node in the deptree.
    It's necessary because, for example, the new device size needs
    to be visible to load the parent table.
  - Preloading is bottom-up. Suspending is top-down.

What's the problem:
  - If a layer LV is inserted, suspend_lv() after that will
    resume the layer LV temporarily before the parent LV is
    suspended.
    It creates a window where both the parent LV and the layer LV
    have the same active table.

For example, in case of adding a mirror,

$ lvconvert -m+1 -vvvv vg/lvol0 2>&1 | egrep 'Suspend|Resum|Load'
#libdm-deptree.c:1463     Loading vg-lvol0_mimage_1 table
#libdm-deptree.c:1463     Loading vg-lvol0_mimage_0 table
#libdm-deptree.c:1463     Loading vg-lvol0_mlog table
#libdm-deptree.c:1463     Loading vg-lvol0_mimagetmp_2 table
#libdm-deptree.c:897     Resuming vg-lvol0_mimagetmp_2 (253:5)
                               ^^^^HERE
#libdm-deptree.c:1463     Loading vg-lvol0_mimage_2 table
#libdm-deptree.c:897     Resuming vg-lvol0_mimage_2 (253:6)
#libdm-deptree.c:1463     Loading vg-lvol0 table
#libdm-deptree.c:940     Suspending vg-lvol0 (253:4)
                               ^^^^HERE
#libdm-deptree.c:940     Suspending vg-lvol0_mimage_1 (253:3)
#libdm-deptree.c:940     Suspending vg-lvol0_mimage_0 (253:2)
#libdm-deptree.c:940     Suspending vg-lvol0_mlog (253:1)

lvol0_mimagetmp_2 is supposed to have the same table as
lvol0 had. lvol0 will be updated to mirror lvol0_mimagetmp_2
and lvol0_mimage_2.
However, lvol0_mimagetmp_2 is resumed before lvol0 is suspended.

The problem is not only for mirror.
For example, adding snapshot has the similar window:

$ lvcreate -l1 -s -vvvv vg/lvol0 2>&1 | egrep 'Suspend|Resum|Load' #libdm-deptree.c:1463     Loading vg-lvol1 table
#libdm-deptree.c:897     Resuming vg-lvol1 (253:2)
#libdm-deptree.c:1463     Loading vg-lvol0-real table
#libdm-deptree.c:897     Resuming vg-lvol0-real (253:3)
                               ^^^^HERE
#libdm-deptree.c:1463     Loading vg-lvol0 table
#libdm-deptree.c:1463     Loading vg-lvol1-cow table
#libdm-deptree.c:897     Resuming vg-lvol1-cow (253:4)
#libdm-deptree.c:1463     Loading vg-lvol1 table
#libdm-deptree.c:940     Suspending vg-lvol0 (253:1) with filesystem sync without device flush
                               ^^^^HERE
#libdm-deptree.c:940     Suspending vg-lvol0-real (253:3) with filesystem sync without device flush

But it might not be a big problem because the mapping is linear.

In case of mirror, the resuming has a side effect (e.g. synching).
So it would be a problem.

Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America
-------------- next part --------------
A non-text attachment was scrubbed...
Name: fix-lvconvert-resume-before-suspend.patch
Type: text/x-patch
Size: 1726 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080125/5c9d59c0/attachment.bin>
