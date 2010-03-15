From: Mike Snitzer <snitzer@redhat.com>
Date: Mon, 15 Mar 2010 15:29:26 -0400
Subject: lv-shared
In-Reply-To: <Pine.LNX.4.64.1003151453350.4733@hs20-bc2-1.build.redhat.com>
References: <Pine.LNX.4.64.1003151453350.4733@hs20-bc2-1.build.redhat.com>
Message-ID: <20100315192925.GA29389@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Mar 15 2010 at  3:00pm -0400,
Mikulas Patocka <mpatocka@redhat.com> wrote:

> Hi
> 
> Why did you hide the "lv-shared" volume? With this hidden, the size and 
> percentage can't be seen.

You can still see it with: lvs -a

I'll have to revisit why I made it hidden (aside from the fact that the
associated DM device is also hidden).  There was some subtle reason that
had to do with the refactoring of associations when I eliminated the
distinct ->shared_snapshot pointer (otherwise the vg_validate() method
would fail).
 
> Also, your changes to 2.02.62 broke shared store resizing.
> lvresize -L 132M vgs/lv-shared no longer works

OK, I can have a look but some of my changes also made it so that
info-by-uuid based multisnapshot cleanup actually works (needed for lvm2
>= 2.02.62).

Mike


