From: Dave Wysochanski <dwysocha@redhat.com>
Date: Thu, 22 Jan 2009 12:36:50 -0500
Subject: [PATCH] Another take on vg_read.
In-Reply-To: <1232619010-4858-1-git-send-email-prockai@redhat.com>
References: <1232619010-4858-1-git-send-email-prockai@redhat.com>
Message-ID: <1232645811.8897.6.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

I went through the list of earlier comments.  Here's what I found that
seems to not have been addressed:


Agk's earlier comments still unaddressed:
1. PATCH6 (old patch#4/11). vg_read_error().
use a typedef for the return value of vg_read_error(), or explain what the
uint32_t means 
https://www.redhat.com/archives/lvm-devel/2009-January/msg00039.html

2. PATCH2. flag naming/definition.
Use a common prefix so they get grouped together.  Line up the 0x0000 parts
vertically making their "single bit" nature more obvious.
https://www.redhat.com/archives/lvm-devel/2009-January/msg00036.html
 
3. PATCH2. EXISTENCE_CHECK definition.
Ambiguous meaning - which is it?  1. self-evident (delete).  2. reserved for
future (say 'reserved').
https://www.redhat.com/archives/lvm-devel/2009-January/msg00036.html

4. PATCH2. _vg_make_handle
naming and possible 'failure' typedef
https://www.redhat.com/archives/lvm-devel/2009-January/msg00037.html

5. PATCH2. _recover_vg()
[note to check call paths later if more than one VG lock is held simultaneously]
https://www.redhat.com/archives/lvm-devel/2009-January/msg00037.html

6. PATCH2. Flag definition.
Some flags (ALLOW_INCONSISTENT) still need comment definitions.
https://www.redhat.com/archives/lvm-devel/2009-January/msg00037.html

7. PATCH2. read_failed member
Let's add a brief comment explaining this one.
read_failed ? Yes or No.  Rename it perhaps?
I think it should be completely separate from 'status' and 'alloc'.
https://www.redhat.com/archives/lvm-devel/2009-January/msg00037.html

8. PATCH2 (old patch#3/11) _vg_check_status
typedef for the return value?
https://www.redhat.com/archives/lvm-devel/2009-January/msg00038.html


Future cleanup:
1. FAILED_READ_ONLY
Note only FAILED_READ_ONLY is used by any tool today - only vgreduce.
Further, FAILED_READ_ONLY can only occur with LVM1 metadata as far as I
can tell.

2. PATCH2. _vg_lock_and_read failure path with invalid name returns NULL.
Note that callling vg_read_error() after hitting this path will return
FAILED_ALLOCATION.  Do we need FAILED_INVALID_NAME or perhaps re-use
FAILED_NOT_FOUND?
https://www.redhat.com/archives/lvm-devel/2009-January/msg00040.html


On Thu, 2009-01-22 at 11:09 +0100, Petr Rockai wrote:
> Hi,
> 
> I have done some more work on this series. I am resending everything, to avoid
> sequencing problems like I introduced last time with a partial send.
> 
> Anyway, some news:
> - the vg_check_status CLUSTERED fallthrough is fixed to return immediately
> - cluster locking is now properly enforced by vg_read/vg_read_for_update
> - process_each_pv is also ported over to new vg_read
> - vg_read_internal is now private in metadata.c (static _vg_read_internal)
> (plus, all patches should apply cleanly on top of today's CVS)
> 
> Hopefully, this moves things forward a little.
> 
> Yours,
>    Petr.
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel


