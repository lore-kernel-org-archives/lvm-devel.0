From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 03 Feb 2009 21:28:54 -0500
Subject: [PATCH] A different implementation of --ignorelockingfailure.
In-Reply-To: <871vuva9yn.fsf@eriador.mornfall.net>
References: <871vuva9yn.fsf@eriador.mornfall.net>
Message-ID: <1233714534.16492.10.camel@localhost.localdomain>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Nice attempt at cleanup.

Not sure about this patch but I do have comments.
1. Why call it 'boottime_locking' - why not readonly_locking which is
clearer?
2. If you make this change you'll also need to modify lvchange.c to take
a READ lock if the request is for an availability change (vgchange has a
conditional).*  Otherwise, lvchange will fail when before it would
succeed.
3. Introducing boottime/readonly as a "type" of locking seems out of
place with the current set of locking types - file operations, cluster
operations.

* Then again, lvchange and vgchange seem to have different code for
changing availability of an LV (?) so there may be a subtle reason
lvchange always takes a WRITE lock.


On Thu, 2009-01-22 at 11:53 +0100, Petr Rockai wrote:
> Hi,
> 
> two ends are addressed by this patch: getting rid of some global state and also
> restricting --ignorelockingfailure to only allow what it is supposed to allow
> (instead of a few hacked-in checks at some places and our belief that the users
> will be well-behaved).
> 
> Yours,
>    Petr.
> 
> --
> lvm-devel mailing list
> lvm-devel at redhat.com
> https://www.redhat.com/mailman/listinfo/lvm-devel


