From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 1 Sep 2008 10:56:51 +0100
Subject: Re: [dm-devel] Re: 2.6.27-rc5-mmotm0829 - lvm issues at boot, possible disk_devt() related?
In-Reply-To: <7045.1220260558@turing-police.cc.vt.edu>
References: <4963.1220240176@turing-police.cc.vt.edu>
	<48BBA0B0.5070309@kernel.org>
	<7045.1220260558@turing-police.cc.vt.edu>
Message-ID: <20080901095651.GI15123@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Sep 01, 2008 at 05:15:58AM -0400, Valdis.Kletnieks at vt.edu wrote:
> On Mon, 01 Sep 2008 09:58:40 +0200, Tejun Heo said:
> > Yeah, I made a mistake converting two of them and devt lookup fails when
> > the disk is zero sized.  Bartlomiej debugged the problem and posted a
> > patch and I followed up with an updated patch.  It should be fine in the
> > next round.
> >   http://article.gmane.org/gmane.linux.kernel.next/2663
> >   http://article.gmane.org/gmane.linux.kernel.next/2676
> > If you're seeing other problems, please let me know.
> Confirming - 2.6.27-rc5-mmotm0829 plus the merge of the 2 above patches
> does find the LVM volumes and come up.  Thanks for the clue.. :)

I expect we'll need some patches to userspace lvm2 to support these extended
device numbers properly too...

Alasdair (back from holiday)
-- 
agk at redhat.com


