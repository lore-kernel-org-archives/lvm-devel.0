From: Petr Rockai <prockai@redhat.com>
Date: Thu, 22 Jan 2009 18:48:14 +0100
Subject: [PATCH] Another take on vg_read.
In-Reply-To: <1232645811.8897.6.camel@localhost.localdomain> (Dave
	Wysochanski's message of "Thu, 22 Jan 2009 12:36:50 -0500")
References: <1232619010-4858-1-git-send-email-prockai@redhat.com>
	<1232645811.8897.6.camel@localhost.localdomain>
Message-ID: <87prif8c69.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dave Wysochanski <dwysocha@redhat.com> writes:
> Agk's earlier comments still unaddressed:
> 1. PATCH6 (old patch#4/11). vg_read_error().
> use a typedef for the return value of vg_read_error(), or explain what the
> uint32_t means 
> https://www.redhat.com/archives/lvm-devel/2009-January/msg00039.html
Yes, I have deferred this.

> 2. PATCH2. flag naming/definition.
> Use a common prefix so they get grouped together.  Line up the 0x0000 parts
> vertically making their "single bit" nature more obvious.
> https://www.redhat.com/archives/lvm-devel/2009-January/msg00036.html
The 0x00 are hopefully lined up now and these look addressed to me. Common
prefix: why? They are far more readable this way and I don't know what prefix
to add, either.

> 3. PATCH2. EXISTENCE_CHECK definition.
> Ambiguous meaning - which is it?  1. self-evident (delete).  2. reserved for
> future (say 'reserved').
> https://www.redhat.com/archives/lvm-devel/2009-January/msg00036.html
This is explained in a comment, and I believe justified as it is.

> 4. PATCH2. _vg_make_handle
> naming and possible 'failure' typedef
> https://www.redhat.com/archives/lvm-devel/2009-January/msg00037.html
It is used to make non-error handles as well, so I don't think it should be
renamed. See the new comment above the function explaining it.

> 5. PATCH2. _recover_vg()
> [note to check call paths later if more than one VG lock is held simultaneously]
> https://www.redhat.com/archives/lvm-devel/2009-January/msg00037.html
This can probably be addressed by not doing any recovery in case DISABLE_LOCK
is given to vg_read?

> 6. PATCH2. Flag definition.
> Some flags (ALLOW_INCONSISTENT) still need comment definitions.
> https://www.redhat.com/archives/lvm-devel/2009-January/msg00037.html
Indeed. ALLOW_INCONSISTENT is explained in _vg_lock_and_read comment. It
probably deserves moving to vg_read description or to the flag definition
itself. (Most other flags are described in vg_read description as well.)

> 7. PATCH2. read_failed member
> Let's add a brief comment explaining this one.
> read_failed ? Yes or No.  Rename it perhaps?
> I think it should be completely separate from 'status' and 'alloc'.
> https://www.redhat.com/archives/lvm-devel/2009-January/msg00037.html
The added comment currently says what 0 and non-0 means and is separate from
both status and alloc. Something else that needs changing there?

> 8. PATCH2 (old patch#3/11) _vg_check_status
> typedef for the return value?
> https://www.redhat.com/archives/lvm-devel/2009-January/msg00038.html
Yes, typedef, see point 1.

> Future cleanup:
> 1. FAILED_READ_ONLY
> Note only FAILED_READ_ONLY is used by any tool today - only vgreduce.
> Further, FAILED_READ_ONLY can only occur with LVM1 metadata as far as I
> can tell.
>
> 2. PATCH2. _vg_lock_and_read failure path with invalid name returns NULL.
> Note that callling vg_read_error() after hitting this path will return
> FAILED_ALLOCATION.  Do we need FAILED_INVALID_NAME or perhaps re-use
> FAILED_NOT_FOUND?
> https://www.redhat.com/archives/lvm-devel/2009-January/msg00040.html
Noted.

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


