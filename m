From: Jun'ichi Nomura <j-nomura@ce.jp.nec.com>
Date: Wed, 06 Feb 2008 17:04:14 -0500
Subject: [PATCH lvconvert 1/2] Fix resume/suspend ordering after temporary mirror insertion
In-Reply-To: <47AA2CBF.1060109@ce.jp.nec.com>
References: <47AA2CBF.1060109@ce.jp.nec.com>
Message-ID: <47AA2EDE.8000309@ce.jp.nec.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

This patch is an updated version of the following:
https://www.redhat.com/archives/lvm-devel/2008-January/msg00134.html

There is a small window during updating the in-kernel dm tables
for stacked LV that the upper device and the lower device have
idential active mappings.
In the current LVM2 features, only lvconvert will suffer from
this problem when adding mirror image(s) to mirror LV.
Attached patch works around the lvconvert problem.


Details are below.

When updating a structure of active LV,
LVM2 preloads new dm table for each device from bottom to top,
then suspend top-down and resume bottom-up.
The preloading includes resuming of lower device so that
a new table for upper device can see the attributes of the
new lower device (i.e. new size).

The point is that the resuming of the lower device happens
before the suspending of the upper device.
If the new table of the lower device and the old table of the
upper device were same and the table contains a target with
side-effect after resume (i.e. mirror and snapshot),
it causes a problem.

In the current LVM2 code, the problem can only occur when
lvconvert adds mirrors to existing mirror.
dev_manager_preload() can check CONVERTING flag in lv->status
to see whether a layer LV is inserted or not.
If inserted, it skips preloading and let the resume code handle it.


Below, I'm trying to explain what's happening using the 'dmsetup ls --tree'
output during "lvconvert adds 1 mirror to 2-way mirrored LV".

lvconvert will change the device tree as follows:

1. Before lvconvert
    vg-lvol0 (253:4)
     |-vg-lvol0_mimage_1 (253:3)
     |-vg-lvol0_mimage_0 (253:2)
     `-vg-lvol0_mlog (253:1)

2. During lvconvert
    vg-lvol0 (253:4)
     |-vg-lvol0_mimage_2 (253:6)
     `-vg-lvol0_mimagetmp_2 (253:5)
        |-vg-lvol0_mimage_1 (253:3)
        |-vg-lvol0_mimage_0 (253:2)
        `-vg-lvol0_mlog (253:1)

3. After lvconvert
    vg-lvol0 (253:4)
     |-vg-lvol0_mimage_2 (253:6)
     |-vg-lvol0_mimage_1 (253:3)
     |-vg-lvol0_mimage_0 (253:2)
     `-vg-lvol0_mlog (253:1)


While moving from the stage 1 to the stage 2,
lvconvert will create a LV 'vg-lvol0_mimage_2' as a new mirror image 
and a layer 'vg-lvol0_mimagetmp_2' to hold the original mirror map:

    vg-lvol0_mimage_2 (253:6)

    vg-lvol0_mimagetmp_2 (253:5)
     |-vg-lvol0_mimage_1 (253:3)
     |-vg-lvol0_mimage_0 (253:2)
     `-vg-lvol0_mlog (253:1)

And vg-lvol0 will mirror them:

    vg-lvol0 (253:4)
     |-vg-lvol0_mimage_2 (253:6)
     `-vg-lvol0_mimagetmp_2 (253:5)

device-mapper operations for the above is actually as follows:
(excerpt from lvconvert-bad.log)

#libdm-deptree.c:1470     Loading vg-lvol0_mimagetmp_2 table
#libdm-deptree.c:1421         Adding target: 0 4096 mirror disk 3 253:1 1024 block_on_error 2 253:2 0 253:3 0
#libdm-deptree.c:897     Resuming vg-lvol0_mimagetmp_2 (253:5)
                               ^^^^HERE
#libdm-deptree.c:1470     Loading vg-lvol0_mimage_2 table
#libdm-deptree.c:1421         Adding target: 0 4096 linear 8:49 384
#libdm-deptree.c:897     Resuming vg-lvol0_mimage_2 (253:6)
#libdm-deptree.c:1470     Loading vg-lvol0 table
#libdm-deptree.c:1421         Adding target: 0 4096 mirror core 2 1024 block_on_error 2 253:5 0 253:6 0
#libdm-deptree.c:940     Suspending vg-lvol0 (253:4)
#libdm-deptree.c:940     Suspending vg-lvol0_mimage_1 (253:3)
#libdm-deptree.c:940     Suspending vg-lvol0_mimage_0 (253:2)
#libdm-deptree.c:940     Suspending vg-lvol0_mlog (253:1)
#libdm-deptree.c:1470     Loading vg-lvol0_mimage_1 table
#libdm-deptree.c:1421         Adding target: 0 4096 linear 8:33 384
#libdm-deptree.c:897     Resuming vg-lvol0_mimage_1 (253:3)
#libdm-deptree.c:1470     Loading vg-lvol0_mimage_0 table
#libdm-deptree.c:1421         Adding target: 0 4096 linear 8:65 384
#libdm-deptree.c:897     Resuming vg-lvol0_mimage_0 (253:2)
#libdm-deptree.c:1470     Loading vg-lvol0_mlog table
#libdm-deptree.c:1421         Adding target: 0 4096 linear 8:34 384
#libdm-deptree.c:897     Resuming vg-lvol0_mlog (253:1)
#libdm-deptree.c:1470     Loading vg-lvol0_mimagetmp_2 table
#libdm-deptree.c:1421         Adding target: 0 4096 mirror disk 3 253:1 1024 block_on_error 2 253:2 0 253:3 0
#libdm-deptree.c:1470     Loading vg-lvol0_mimage_2 table
#libdm-deptree.c:1421         Adding target: 0 4096 linear 8:49 384
#libdm-deptree.c:897     Resuming vg-lvol0 (253:4)

Note that at the line commented with "HERE" above,
both vg-lvol0 and vg-lvol0_mimagetmp_2 are active and
having the same structure:

    vg-lvol0 (253:4)
     |-vg-lvol0_mimage_1 (253:3)
     |-vg-lvol0_mimage_0 (253:2)
     `-vg-lvol0_mlog (253:1)

It happens because the preloading is done before suspending.
Attached patch disables preloading if CONVERTING is on.


With the patch, vg-lvol0 is suspended first.
So the operations look like this: (excerpt from lvconvert-good.log)

#libdm-deptree.c:940     Suspending vg-lvol0 (253:4)
#libdm-deptree.c:940     Suspending vg-lvol0_mimage_1 (253:3)
#libdm-deptree.c:940     Suspending vg-lvol0_mimage_0 (253:2)
#libdm-deptree.c:940     Suspending vg-lvol0_mlog (253:1)
#libdm-deptree.c:1470     Loading vg-lvol0_mimage_1 table
#libdm-deptree.c:1421         Adding target: 0 4096 linear 8:33 384
#libdm-deptree.c:897     Resuming vg-lvol0_mimage_1 (253:3)
#libdm-deptree.c:1470     Loading vg-lvol0_mimage_0 table
#libdm-deptree.c:1421         Adding target: 0 4096 linear 8:65 384
#libdm-deptree.c:897     Resuming vg-lvol0_mimage_0 (253:2)
#libdm-deptree.c:1470     Loading vg-lvol0_mlog table
#libdm-deptree.c:1421         Adding target: 0 4096 linear 8:34 384
#libdm-deptree.c:897     Resuming vg-lvol0_mlog (253:1)
#libdm-deptree.c:1470     Loading vg-lvol0_mimagetmp_2 table
#libdm-deptree.c:1421         Adding target: 0 4096 mirror disk 3 253:1 1024 block_on_error 2 253:2 0 253:3 0
#libdm-deptree.c:897     Resuming vg-lvol0_mimagetmp_2 (253:5)
#libdm-deptree.c:1470     Loading vg-lvol0_mimage_2 table
#libdm-deptree.c:1421         Adding target: 0 4096 linear 8:49 384
#libdm-deptree.c:897     Resuming vg-lvol0_mimage_2 (253:6)
#libdm-deptree.c:1470     Loading vg-lvol0 table
#libdm-deptree.c:1421         Adding target: 0 4096 mirror core 2 1024 block_on_error 2 253:5 0 253:6 0
#libdm-deptree.c:897     Resuming vg-lvol0 (253:4)


Thanks,
-- 
Jun'ichi Nomura, NEC Corporation of America

-------------- next part --------------
A non-text attachment was scrubbed...
Name: fix-dont-preload-after-layer-insertion.patch
Type: text/x-patch
Size: 1757 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20080206/bb3a228e/attachment.bin>
