From: Dave Wysochanski <dwysocha@redhat.com>
Date: Mon, 26 Apr 2010 14:01:21 -0400
Subject: [PATCH 09/22] Replicator: add sorted vgs_list
In-Reply-To: <4BD5A982.80602@redhat.com>
References: <cover.1271085009.git.zkabelac@redhat.com>
	<4ac472dac5d9b6fe6833e169e5ccddceab1fa014.1271085009.git.zkabelac@redhat.com>
	<20100426143404.GR23791@agk-dp.fab.redhat.com>
	<4BD5A982.80602@redhat.com>
Message-ID: <1272304881.2478.3.camel@f10-node1>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, 2010-04-26 at 16:56 +0200, Zdenek Kabelac wrote:
> Dne 26.4.2010 16:34, Alasdair G Kergon napsal(a):
> > On Mon, Apr 12, 2010 at 05:21:37PM +0200, Zdenek Kabelac wrote:
> >> Introduce struct vgs_list to store information about needed
> >> volume group name, vgid, flags and the pointer to opened VG.
> >  
> > Why does this need a new structure?
> 
> We don't have any similar one - I would be aware of.
> 

It will likely also be very useful for certain library operations that
involve multiple VGs (vgsplit, vgmerge) - I started looking at
refactoring the vgsplit/vgmerge code to use this new structure (or
something very close to it).


