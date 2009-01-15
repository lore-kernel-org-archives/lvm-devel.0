From: Petr Rockai <prockai@redhat.com>
Date: Thu, 15 Jan 2009 10:25:20 +0100
Subject: [PATCH 2/11] Provide _vg_lock_and_read, a new implementation of lock+vg_read_internal.
In-Reply-To: <1231861645.5073.27.camel@localhost.localdomain> (Dave
	Wysochanski's message of "Tue, 13 Jan 2009 10:47:25 -0500")
References: <1231769286-15534-1-git-send-email-prockai@redhat.com>
	<1231769286-15534-2-git-send-email-prockai@redhat.com>
	<1231769286-15534-3-git-send-email-prockai@redhat.com>
	<1231861645.5073.27.camel@localhost.localdomain>
Message-ID: <87ljtc3oqn.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dave Wysochanski <dwysocha@redhat.com> writes:
> Note only FAILED_READ_ONLY is used by any tool today - only vgreduce.
> Further, FAILED_READ_ONLY can only occur with LVM1 metadata as far as I
> can tell.
Could be. I'd propose to address this separately though, since I suppose we
want to change semantics of things for this -- make the read-only failure
deprecated and maybe just issue a warning whenever the flag is encountered,
when opening read-write?

>> +	if (!validate_name(vg_name) && !is_orphan_vg(vg_name)) {
>> +		log_error("Volume group name %s has invalid characters",
>> +			  vg_name);
>> +		return NULL;
>> +	}
>
> Is there a reason to return NULL here when a handle with an error code
> is returned everywhere else?
>
> Note that callling vg_read_error() after hitting this path will return
> FAILED_ALLOCATION.  Do we need FAILED_INVALID_NAME or perhaps re-use
> FAILED_NOT_FOUND?
Basically, the reason is just that no tool ever seems to care. It's true that
it's not very nice to turn up FAILED_ALLOCATION, but in case that's what API
user gets, they should just abort anyway -- the library code has already
printed the error message (like it is the case here). We could differentiate
that though, I have no strong opinion. Maybe add a patch on top though.

Yours,
   Petr.

PS: I am sending an amended patch in a while (re. Alasdair's comments), I just
need to rebase the rest of the stack on top and check that tests still pass,
ie. I didn't botch the thing inadvertently.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


