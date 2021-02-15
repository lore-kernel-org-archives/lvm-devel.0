From: David Teigland <teigland@redhat.com>
Date: Mon, 15 Feb 2021 10:31:27 -0600
Subject: Question: the failure handling for sanlock
In-Reply-To: <20210214101303.GA399193@leoy-ThinkPad-X240s>
References: <20210214101303.GA399193@leoy-ThinkPad-X240s>
Message-ID: <20210215163127.GA25608@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sun, Feb 14, 2021 at 06:13:03PM +0800, Leo Yan wrote:
>  538         /*
>  539          * FIXME: here is where we should implement a strong form of
>  540          * blkdeactivate, and if it completes successfully, automatically call
>  541          * do_drop() afterward.  (The drop step may not always be necessary
>  542          * if the lvm commands run while shutting things down release all the
>  543          * leases.)
>  544          *
>  545          * run_strong_blkdeactivate();
>  546          * do_drop();
>  547          */
> 
> My first question is why lvmlockctl comments out the failure handling code so
> cannot automatically deactivate drives and cleanup VG/LV locks by default?

Only because that forceful deactivate has not been implemented.

> The second question is what's a suggested flow for failure handling for sanlock?
> If I understand correctly, we can rely on the command "blkdeactivate" to
> deactivates block devices; but if we deactivate the whole block device, it
> might also hurt other VGs/LVs resident on the same drive.  So should we firstly
> deactivate VGs or LVs with "vgchange" or "lvchange" commands rather than
> deactivate the whole block device?  We might consider there have no chance to
> access drive for the drive or fabric malfunction, so cannot make succuss for
> commands "vgchange" and "lvchange".

We only need to forcefully deactivate LVs in the failed VG.  The lvmlockd
man page section "sanlock lease storage failure" describes how this
process can work manually, and mentions doing it automatically in the
future.  In the manual process you'd try to stop applications using the
fs, unmount file systems on the LVs, then try to deactivate the LVs.
Since there are storage issues, the unmount and deactivate might hang, in
which case you could try dmsetup wipe_table on the LVs.  You might just
skip immediately to that last step since there's not a lot of time.

There was a script written in 2017 to automate that final dmsetup step.
It was finished or very close, but I don't remember what kept us from
including it.  An idea to make dmsetup do more of the work perhaps left us
unsure what to do.  Here is the script and some discussion:
https://listman.redhat.com/archives/lvm-devel/2017-September/msg00011.html

There was also a small lvmlockctl patch to replace the
run_strong_blkdeactivate() comment with running the script.

If you can get this to work for your case I'd like to get it included in
lvm.

Dave


