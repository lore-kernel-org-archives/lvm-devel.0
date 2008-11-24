From: Petr Rockai <prockai@redhat.com>
Date: Mon, 24 Nov 2008 16:19:49 +0100
Subject: [PATCH] (11/11) re-instantiate automatic VG recovery
In-Reply-To: <1227498917.6608.14.camel@localhost.localdomain> (Dave
	Wysochanski's message of "Sun, 23 Nov 2008 22:55:17 -0500")
References: <87fxme2amo.fsf@eriador.mornfall.net>
	<1227498917.6608.14.camel@localhost.localdomain>
Message-ID: <87zljp6tii.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dave Wysochanski <dwysocha@redhat.com> writes:
> 1) Is there a reason you dropped the "if (lockingfailed()) return NULL"
> from your version?  The original recover_vg() in toollib had this:
> struct volume_group *recover_vg(struct cmd_context *cmd, const char *vgname,
> 				uint32_t lock_type)
> {
> 	int consistent = 1;
>
> 	/* Don't attempt automatic recovery without proper locking */
> 	if (lockingfailed())
> 		return NULL;
>
> 	lock_type &= ~LCK_TYPE_MASK;
> 	lock_type |= LCK_WRITE;

This is not a problem, since in case of locking failure, _recover_vg is never
called (it is not exported from the file, and is only called in one
place). Moreover, lockingfailed() is a piece of global knowledge I would love
to get rid of.

> 2) Note that in some of the original paths (e.g. vgconvert) that called
> recover_vg(), there was a call to "dev_close_all()", while others did
> not (e.g. process_each_lv()).

I believe that adding dev_close_all() could work, but it looks like a
workaround of some sort, since from looking at the definition of dev_close_all,
it should just scavenge open fd's that are no longer in use.

Now from reading _dev_close, it seems that we don't close devices whose
refcount drop to 0, if they are part of a locked VG. This is probably where
dev_close_all kicks in, and I'll note down to add it to the _recover_vg path,
every time.

> 3) Previous to this, in the case of inconsistent metadata, we sometimes
> would do recovery while others we would not.  Now we're doing recovery
> in all cases?  Is this what we want, especially with the reporting
> tools?

Yes, I believe we want to do recovery every time we have write access, since
the intention of this (and the "recover" bits should be renamed to reflect
that) to finish incomplete transactions.

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


