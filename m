From: Mike Snitzer <snitzer@redhat.com>
Date: Fri, 19 Mar 2010 22:04:46 -0400
Subject: Don't allow resizing of internal logical volumes
In-Reply-To: <20100319234417.GB31274@redhat.com>
References: <Pine.LNX.4.64.1003181950140.29893@hs20-bc2-1.build.redhat.com>
	<20100319200807.GC7345@redhat.com>
	<Pine.LNX.4.64.1003191823570.7833@hs20-bc2-1.build.redhat.com>
	<20100319234417.GB31274@redhat.com>
Message-ID: <20100320020445.GA13275@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Mar 19 2010 at  7:44pm -0400,
Mike Snitzer <snitzer@redhat.com> wrote:

> On Fri, Mar 19 2010 at  6:27pm -0400,
> Mikulas Patocka <mpatocka@redhat.com> wrote:
> 
> > OK. It is cleaner than my patch that checks the name, so commit it (except 
> > !lv_is_accessible_hidden(lv), because that has to wait until we commit 
> > shared snapshots).
> > 
> > I tested it and it refuses "snapshotX" volumes.
> 
> But as you said above: "snapshot0 volumes have the VISIBLE_LV flag set."
> 
> That said, I do see that in practice the existing lvm2 code does reject
> resizing "snapshot" type snapshot0 using !lv_is_visible(lv).  I'll have
> a closer look to understand that.

lv_is_visible() prevents resize on "snapshot" type snapshot0 because of
this out: (lv->status & SNAPSHOT)

As you suggested, I'll commit the lv_is_visible() change to tools/lvresize.c

> But when I tried it with the "multisnapshot" type snapshot0 (w/
> multisnap enabled LVM2 2.02.63 from my people page + the above patch)
> lvresize allowed it and then crashed in _setup_alloced_segment():

I've added the same out in lv_is_accessible_hidden() and this prevents
the "multisnapshot" type snapshot0 from being resized:

int lv_is_accessible_hidden(const struct logical_volume *lv)
{
        if (lv->status & SNAPSHOT)
                return 0;

        if (lv_is_cow(lv))
                return (find_cow(lv)->lv->status & ACCESS_HIDDEN_LV) ? 1 : 0;

        return (lv->status & ACCESS_HIDDEN_LV) ? 1 : 0;
}



