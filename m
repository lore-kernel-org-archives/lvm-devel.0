From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 7 Jul 2009 22:55:23 +0100
Subject: [PATCH 7/7] Add lvm_vg_create() - vg constructor API for new volume groups.
In-Reply-To: <4A5324B3.5080905@redhat.com>
References: <1246953008-27609-1-git-send-email-dwysocha@redhat.com>
	<1246953008-27609-2-git-send-email-dwysocha@redhat.com>
	<1246953008-27609-3-git-send-email-dwysocha@redhat.com>
	<1246953008-27609-4-git-send-email-dwysocha@redhat.com>
	<1246953008-27609-5-git-send-email-dwysocha@redhat.com>
	<1246953008-27609-6-git-send-email-dwysocha@redhat.com>
	<1246953008-27609-7-git-send-email-dwysocha@redhat.com>
	<1246953008-27609-8-git-send-email-dwysocha@redhat.com>
	<4A5324B3.5080905@redhat.com>
Message-ID: <20090707215523.GK11082@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Jul 07, 2009 at 12:34:27PM +0200, Milan Broz wrote:
> > +		if (!vg_set_extent_size(vg_to, vp_new.extent_size) ||
> > +		    !vg_set_max_lv(vg_to, vp_new.max_lv) ||
> > +		    !vg_set_max_pv(vg_to, vp_new.max_pv) ||
> > +		    !vg_set_alloc(vg_to, vp_new.alloc))
> >  			goto_bad;
 
> I like the old way much more better...
 
Applications using the defaults won't need to call any of those, and
eventually lvm2 tools should call them while processing any
corresponding cmdline args where non-default values are requested.

Alasdair


