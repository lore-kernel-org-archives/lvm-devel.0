From: Mikulas Patocka <mpatocka@redhat.com>
Date: Tue, 9 Feb 2010 18:59:45 -0500 (EST)
Subject: false error messages when merging
In-Reply-To: <20100208224314.GC21695@redhat.com>
References: <Pine.LNX.4.64.1002081542190.13894@hs20-bc2-1.build.redhat.com>
	<20100208212904.GA21695@redhat.com> <20100208220326.GB21695@redhat.com>
	<20100208224314.GC21695@redhat.com>
Message-ID: <Pine.LNX.4.64.1002091859150.14493@hs20-bc2-1.build.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit



On Mon, 8 Feb 2010, Mike Snitzer wrote:

> On Mon, Feb 08 2010 at  5:03pm -0500,
> Mike Snitzer <snitzer@redhat.com> wrote:
> 
> > On Mon, Feb 08 2010 at  4:29pm -0500,
> > Mike Snitzer <snitzer@redhat.com> wrote:
> > 
> > > On Mon, Feb 08 2010 at  3:49pm -0500,
> > > Mikulas Patocka <mpatocka@redhat.com> wrote:
> > > 
> > > > Hi
> > > > 
> > > > LVM2.2.02.60 writes false error messages about tree node not found when 
> > > > activating delayed merging. But it starts merging anyway.
> > > > 
> > > > [slunicko:~]# lvs
> > > >   LV   VG   Attr   LSize  Origin Snap%  Move Log Copy%  Convert
> > > >   m    vg1  -wi-a- 16.00m
> > > > [slunicko:~]# lvcreate -s -n s -c 4k -L 24M vg1/m
> > > >   Logical volume "s" created
> > > > [slunicko:~]# mount -t ext2 /dev/vg1/s /mnt/test
> > > > [slunicko:~]# lvconvert --merge /dev/vg1/s
> > > >   Can't merge when snapshot is open
> > > >   Merging of snapshot s will start next activation.
> > > > [slunicko:~]# umount /mnt/test
> > > > [slunicko:~]# lvchange -an vg1/m
> > > > [slunicko:~]# lvchange -ay vg1/m
> > > >   failed to find tree node for m
> > > >   failed to find tree node for s
> > > > [slunicko:~]#
> > > > ... the merging starts on backgound fine
> > > 
> > > I can reproduce your "failed to find tree node for" scenario using
> > > the steps you provided.
> > ...
> > > All this being said, I'm not sure what's going on with your scenario but
> > > I'll get to the bottom of it.
> > 
> > So this "failed to find tree node for" message was introduced with my
> > optimization for not issuing more ioctls than is needed for checking
> > open_count: http://sources.redhat.com/git/?p=lvm2.git;a=commit;h=1199b48c
> > 
> > I'll dig deeper to see what I can do about the noise.
> 
> The following patch eliminates the false error entirely.  I'm leaning
> toward removing the message (rather than switch to log_debug()) because
> it is valid (and expected) to not have a node in the tree (for both the
> merging origin and the merging snapshot) in the case of when we're
> activating a merging origin.
> 
> diff --git a/lib/activate/dev_manager.c b/lib/activate/dev_manager.c
> index 6023574..6fbc392 100644
> --- a/lib/activate/dev_manager.c
> +++ b/lib/activate/dev_manager.c
> @@ -264,10 +264,9 @@ static const struct dm_info *_cached_info(struct dm_pool *mem,
>  		return NULL;
>  	}
>  
> -	if (!(dnode = dm_tree_find_node_by_uuid(dtree, dlid))) {
> -		log_error("failed to find tree node for %s", lv->name);
> +	/* An activating merging origin won't have a node in the tree yet */
> +	if (!(dnode = dm_tree_find_node_by_uuid(dtree, dlid)))
>  		return NULL;
> -	}
>  
>  	if (!(dinfo = dm_tree_node_get_info(dnode))) {
>  		log_error("failed to get info from tree node for %s", lv->name);
> 

OK.

Reviewed-by: Mikulas Patocka <mpatocka@redhat.com>

Mikulas


