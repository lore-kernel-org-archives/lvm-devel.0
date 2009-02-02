From: Petr Rockai <prockai@redhat.com>
Date: Tue, 03 Feb 2009 00:45:01 +0100
Subject: [PATCH 06/13] Add lvm_vg_close().
In-Reply-To: <1233607809-1087-7-git-send-email-dwysocha@redhat.com> (Dave
	Wysochanski's message of "Mon, 2 Feb 2009 15:50:02 -0500")
References: <1233607809-1087-1-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-2-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-3-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-4-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-5-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-6-git-send-email-dwysocha@redhat.com>
	<1233607809-1087-7-git-send-email-dwysocha@redhat.com>
Message-ID: <87d4e0769u.fsf@eriador.mornfall.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dave Wysochanski <dwysocha@redhat.com> writes:
> +void lvm_vg_close(vg_t *vg)
> +{
> +	if (vgname_is_locked(vg->name))
> +		unlock_vg(vg->cmd, vg->name);
> +}
Do we want to do reference counting in here? Might be moot if we don't allow
multiple opens. But contrary to what I said on IRC last time, it might be worth
to have proper lock upgrading procedure, and it would be sort of nice if that
could be achieved (for the user) by just calling the open function again on the
same VG, with write permission request. One use case is automated recovery,
which could be probably reformulated elegantly in terms of a lock upgrade.

Another is the one you have mentioned, "read in the vg, wibble around a little
and then decide you want to change it". The solution I proposed back then, to
close and open for writing again, is inherently race-prone, so you would need
to do all your wibbling again. Of course, the lock upgrade might fail, in which
case, you will have to anyway, but maybe it still makes the API a little more
friendly and less tempting to do the wrong thing.

However, now I think about it, even that probably doesn't need refcounting if
we structure the lock upgrade API accordingly. Ok, clear.

I'm getting pretty tangential now, but another thought: should be the locking
state encapsulated in the library handle, as opposed to process-global? This
probably depends whether the locks can actually prevent the same process (in
say different thread) from acquiring the lock second time (ie. whether they are
effective in preventing unintended concurrent accesses from same process). If
they are, it wouldn't be so hard to make the proposed lvmlib API thread-safe,
by requiring that each thread owns its own library handle. This might be of
direct benefit to eg. dmeventd, which currently has a fairly ugly mutex hack
instead.

Sorry for the tangential reply...

Petr.

-- 
Peter Rockai | me()mornfall!net | prockai()redhat!com
 http://blog.mornfall.net | http://web.mornfall.net

"In My Egotistical Opinion, most people's C programs should be
 indented six feet downward and covered with dirt."
     -- Blair P. Houghton on the subject of C program indentation


