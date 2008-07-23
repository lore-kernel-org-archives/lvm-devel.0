From: Jonathan Brassow <jbrassow@redhat.com>
Date: Wed, 23 Jul 2008 15:44:14 -0500
Subject: RFC: Idea for fixing broken mirror -> mirror up converts
Message-ID: <1216845854.6797.21.camel@hydrogen>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Please refer to the following thread for history on this subject:
https://www.redhat.com/archives/lvm-devel/2008-February/msg00007.html

Associated bug:
https://bugzilla.redhat.com/show_bug.cgi?id=455670

I'd like to address the first point in the above e-mail.  That is:
<jnomura>
lvconvert has problems where 2 active mirror maps coexist
for a short while sharing the same log device.
That is critical to cluster mirror as it detects such situation
but also dangerous to non-clustered mirror.

The problems are:

  1. resume before suspend

      When a layer is inserted beneath a LV, the layer is
      resumed before the LV is suspended.

      I.e. if the LV is active, lvconvert calls suspend_lv() for
      the LV to suspend the LV preparing for the update:

        suspend_lv()
          _lv_suspend()
            _lv_preload()
              dev_manager_preload()
                dm_tree_preload_children()
                  Load tables for devices from bottom to top.
                  If a device has parents, resume the device, too.
            _lv_suspend_lv()
              dev_manager_suspend()

      However, before actually suspend the LV, suspend_lv() will end
      up calling dm_tree_preload_children() that involves resuming
      of the layer.
</jnomura>

Here is the log from his lvconvert (entire logs can be found in the referenced e-mail):
<lvconvert-bad.log>
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
</lvconvert-bad.log>

jnomura points out that the resume (marked 'HERE') causes two copies of
the same mirror to exists and be active in the kernel at the same time.
This is because a 'suspend' causes devices to "preload" (and resume)
before the actual suspend takes place.

jnomura's solution was to skip the preload if the mirror was converting.
The argument against this was that the new devices are then allocated
while devices are suspended... leading to potential allocation issues.

I propose going deeper down the stack to solve the problem.  It is
the /resume/ that is causing the problem (marked with 'HERE' above), not
the creation of preloaded devices.  Lets remove the 'resume' portion of
the preload action.  After all, there is no reason to 'resume' new
devices if we are in the process of suspending anyway - it is a wasted
operation.  Doing this will allow us to skip the resume - fixing the
problem with simultaneous active tables to the same mirror; and it
allows us to preload (and construct) tables - clearing objections rooted
in allocation concerns.

For this solution, we would likely need to break up '_lv_preload' (or
add an extra parameter) to signify whether or not we want to do a resume
following the loading of the tables.  '_lv_preload_noresume' would be
used by '_lv_suspend'.

Tell me what you think,
 brassow



