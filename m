From: Petr Rockai <prockai@redhat.com>
Date: Tue, 26 May 2009 19:33:13 +0200
Subject: [PATCH] Fix CLUSTERED flag in new _vg_read_for_update() and vg_read().
In-Reply-To: <1243356748-22653-1-git-send-email-dwysocha@redhat.com> (Dave
	Wysochanski's message of "Tue, 26 May 2009 12:52:28 -0400")
References: <1243356748-22653-1-git-send-email-dwysocha@redhat.com>
Message-ID: <8763fnzs4m.fsf@mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dave Wysochanski <dwysocha@redhat.com> writes:
> In the new _vg_read_for_update(), we always do the check for CLUSTERED vg
> status flag after reading the volume group.  Thus, no need to set the flag
> in vg_read() or clear it later before calling _vg_bad_status_bits().
Ok, makes sense.

> Also, add back in the !lockingfailed() as part of the CLUSTERED flag check.
> It's unclear why it was removed when the check was moved from
> _vg_bad_status_bits() to inside _vg_lock_and_read().
There is a patch floating somewhere removing lockingfailed() altogether, since
it's an ugly piece of global state (a rampant modularity violation, if you
will). But I concede to have it put back, although I don't really know what its
effect here would be, anyway (don't report errors when cluster locking failed?
why?).

Yours,
   Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


