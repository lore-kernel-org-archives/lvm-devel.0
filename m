From: David Teigland <teigland@redhat.com>
Date: Mon, 13 Jan 2020 11:15:42 -0600
Subject: Question: lvmlockd adopts orphan locks
In-Reply-To: <20200109081953.GA24047@leoy-ThinkPad-X240s>
References: <20200109081953.GA24047@leoy-ThinkPad-X240s>
Message-ID: <20200113171542.GB23041@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, Jan 09, 2020 at 04:19:53PM +0800, Leo Yan wrote:
> Hi all,
> 
> Since the commit 117160b27e51 ("Remove lvmetad") has been merged into
> lvm2 git repository, lvmetad is removed.
> 
> As side effect, in lvmlockd the function get_lockd_vgs() returns -1.
> Thus it's no chance for lvmlockd to adopt orphan locks after the
> lvmlockd exits abnormal and relaunch.   If we connect with the sanlock
> lock manager, its daemon keeps running on the host and renew all
> locks, this would be safe for the in used LV on the host; but on the
> other hand, lvmlockd cannot adopt the locks, thus we have no chance to
> release related LVM locks anymore.
> 
> For this case, I understand we can release locks by directly use low
> level sanlock commands, just wander if we have more smooth approach for
> lvmlockd to adopt locks and release the locks gracefully after lvmlockd
> failure?  Or do I miss anything?

You are correct.  I have not yet replaced the lock-adoption code in
lvmlockd because it was not clear that anyone was using it.  I'm happy
to hear that it was useful for you, and sorry that it's been disabled.
I hope to have it replaced in the coming year, and would be happy to
help anyone interested in working on it.

Dave


