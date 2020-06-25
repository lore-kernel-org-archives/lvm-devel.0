From: David Teigland <teigland@redhat.com>
Date: Thu, 25 Jun 2020 09:55:23 -0500
Subject: Question: LVM2 testing with sanlock lock manager
In-Reply-To: <20200625093411.GB19777@leoy-ThinkPad-X240s>
References: <20200625093411.GB19777@leoy-ThinkPad-X240s>
Message-ID: <20200625145523.GA23434@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Jun 25, 2020 at 05:34:12PM +0800, Leo Yan wrote:
> Hi there,
> 
> I have one question for LVM test suites with sanlock locking manager.
> After tried both the master branch and with the LVM v2 (with the tag
> 'v2_02_187'), the testing seems to me is fragile.

Hi, we switched to using check_lvmlockd_test (running lvmlockd in test
mode without a lock manager backend) because it accomplished most of what
we needed in a much simpler way.  Also, a forcable cleanup of the lock
managers after a test failure had problems I never fully resolved.  And,
the value of check_lvmlockd_sanlock and check_lvmlockd_dlm is limited
since these are local tests.  As you've seen, I left the old methods
around in case someone found a use for them.

> I observed some below issues:
> 
> - The sanlock daemon preparation script
>   test/shell/aa-lvmlockd-sanlock-prepare.sh has several issues, e.g.
>   the dmsetup command cannot work well for global lock; the
>   gl_file.img is stored in the temporary folder and it will be removed
>   after the script aa-lvmlockd-sanlock-prepare.sh is finished, so
>   gl_file.img cannot be used cross all sequential test cases.  Thus
>   the global lock will malfunction for this case.
> 
>   Have sent related patches to lvm-devel mailing list for this.
> 
> - I also compared the testing result between DLM and sanlock, if I
>   using DLM as the locking scheme, the testing result is quite
>   reliable.  But for sanlock related testing, the testing cases have
>   many failures, even after fixed the observed issues in
>   aa-lvmlockd-sanlock-prepare.sh, still can see many failures.
> 
>   I used the command as below:
>   make check_lvmlockd_sanlock LVM_TEST_BACKING_DEVICE=/dev/sdj3 S=component-cache.sh
> 
>   From the testing I found, component-cache.sh is easily cause stuck
>   at the last command to remove VG and after the testing case
>   lvconvert-cache-chunks.sh the almost later cases fail.  So the final
>   testing result is:
>   ### 330 tests: 34 passed, 98 skipped, 0 timed out, 1 warned, 197 failed
> 
> Could you kindly confirm if I miss something (configurations, or
> should co-work with DLM) for sanlock related testing?

Thanks for the patches.  There are some issues that prevent a number of
tests from being used with check_sanlock, the main one being the internal
lvmlock LV that holds the sanlock locks and keeps one of the PVs in use.
We sometimes change the tests so they'll work, or will flag them to skip
with sanlock.  I will try component-cache.sh to see if that's the issue,
or something else.

Dave


