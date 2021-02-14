From: Leo Yan <leo.yan@linaro.org>
Date: Sun, 14 Feb 2021 18:13:03 +0800
Subject: Question: the failure handling for sanlock
Message-ID: <20210214101303.GA399193@leoy-ThinkPad-X240s>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi there,

I have couple questions for the drive failure handling for sanlock; let me
elaborate for the questions:

If any drive or fabric failures happen and it's impossible to access the
drives, thus the sanlock lock manager fails to renew the lease for locks.
In this case, as described in the sanlock wrapper of lvmlockd [1], it firstly
invokes command 'lvmlockctl --kill vg_name' to prevent lvmlockd to handle any
further requests for the VG which is killed; and it "attempts to quit using
the VG."

For "quit using the VG", the comment suggests to use blkdeactivate() or a more
forceful equivalent method to disable block devices, and needs to release
lease for VG/LV locks.  But as we can see, in the code of lvmlockctl, it
comments out the failure handling operations [2]:

 538         /*
 539          * FIXME: here is where we should implement a strong form of
 540          * blkdeactivate, and if it completes successfully, automatically call
 541          * do_drop() afterward.  (The drop step may not always be necessary
 542          * if the lvm commands run while shutting things down release all the
 543          * leases.)
 544          *
 545          * run_strong_blkdeactivate();
 546          * do_drop();
 547          */

My first question is why lvmlockctl comments out the failure handling code so
cannot automatically deactivate drives and cleanup VG/LV locks by default?
I think one possible reason is lvmlockd gives the priority for DLM locking scheme,
the DLM lock manager is based on networking protocol, and DLM has its path for
failure handling, like using pace maker and CPG [3].  But on the other hand, this
means the current implementation for lvmlockd/lvmlockctl is absent to support
driver failure handling by default and need to manually deactivate block devices.

The second question is what's a suggested flow for failure handling for sanlock?
If I understand correctly, we can rely on the command "blkdeactivate" to
deactivates block devices; but if we deactivate the whole block device, it
might also hurt other VGs/LVs resident on the same drive.  So should we firstly
deactivate VGs or LVs with "vgchange" or "lvchange" commands rather than
deactivate the whole block device?  We might consider there have no chance to
access drive for the drive or fabric malfunction, so cannot make succuss for
commands "vgchange" and "lvchange".

Hope I have described my questions clearly, if no, please let me know.
And thanks in advance for suggestions!

Leo

[1] https://sourceware.org/git/?p=lvm2.git;a=blob;f=daemons/lvmlockd/lvmlockd-sanlock.c;h=4bc6402cf85a374a49695c6bca5bc10a7e5f042b;hb=refs/heads/master#l119
[2] https://sourceware.org/git/?p=lvm2.git;a=blob;f=daemons/lvmlockd/lvmlockctl.c;h=c2a998c8c4a19bdf835d1020c64af2e8918c3915;hb=refs/heads/master#l539
[3] https://pagure.io/dlm/blob/master/f/dlm_controld/cpg.c#_46


