From: Dave Wysochanski <dwysocha@redhat.com>
Date: Tue, 16 Mar 2010 18:20:00 -0400
Subject: [PATCH] Fix pvcreate device check.
In-Reply-To: <4B9E3399.2020800@redhat.com>
References: <1268658848-24437-1-git-send-email-mbroz@redhat.com>
	<4B9E3399.2020800@redhat.com>
Message-ID: <1268778001.2418.9.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, 2010-03-15 at 14:18 +0100, Milan Broz wrote:
> On 03/15/2010 02:14 PM, Milan Broz wrote:
> > @@ -1294,17 +1294,9 @@ static int pvcreate_check(struct cmd_context *cmd, const char *name,
> >  
> >  	/* Is there an md superblock here? */
> >  	if (!dev && md_filtering()) {
> > -		unlock_vg(cmd, VG_ORPHANS);
> > -
> > -		persistent_filter_wipe(cmd->filter);
> > -		lvmcache_destroy(cmd, 1);
> > -
> > +		refresh_filters(cmd);
> >  		init_md_filtering(0);
> > -		if (!lock_vol(cmd, VG_ORPHANS, LCK_VG_WRITE)) {
> > -			log_error("Can't get lock for orphan PVs");
> > -			init_md_filtering(1);
> > -			return 0;
> > -		}
> 
> 
> > +		lvmcache_label_scan(cmd, 0);
> 
> even this rescan line is not needed, device must be in cache already,
> just it is filtered out by MD filter.
> 
> Milan
> 

Ack.  Thanks for cleaning up this code wart Milan!


