From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 20 Apr 2010 00:25:10 +0100
Subject: LVM2 ./WHATS_NEW ./WHATS_NEW_DM libdm/libdm-de ...
In-Reply-To: <20100419223820.GA11273@redhat.com>
References: <20100407200443.26841.qmail@sourceware.org>
	<20100419223820.GA11273@redhat.com>
Message-ID: <20100419232509.GG4828@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Apr 19, 2010 at 06:38:20PM -0400, Mike Snitzer wrote:
> On Wed, Apr 07 2010 at  4:04pm -0400,
> agk at sourceware.org <agk@sourceware.org> wrote:
 
> >  		/* Refresh open_count */
> >  		if (!_info_by_dev(dinfo->major, dinfo->minor, 1, &info) ||
> > -		    !info.exists || info.open_count)
> > +		    !info.exists)
> >  			continue;
> >  
> > +		if (info.open_count) {

> It would appear that the non-zero open_count associated with the -real
> device is stale (during lvremove's dm_tree_deactivate_children).  

Shouldn't be - it follows a 'refresh'.

Alasdair


