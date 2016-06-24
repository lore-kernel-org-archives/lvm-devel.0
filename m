From: Liuhua Wang <lwang@suse.com>
Date: Fri, 24 Jun 2016 17:32:12 +0800
Subject: [PATCH] dev-type: add support for checking sgi/sun partition table
In-Reply-To: <20160505015849.GB24139@agk-dp.fab.redhat.com>
References: <1459317281-15471-1-git-send-email-lwang@suse.com>
	<20160505013823.GA6535@wlh-host.lab.bej.apac.novell.com>
	<20160505015849.GB24139@agk-dp.fab.redhat.com>
Message-ID: <20160624093212.GA12218@wlh-host.bej.suse.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Alasdair,

Sorry for late reply.

On Thu, May 05, 2016 at 02:58:49AM +0100, Alasdair G Kergon wrote:
> On Thu, May 05, 2016 at 09:38:23AM +0800, Liuhua Wang wrote:
> > Would you please review my patch?
> 
> Do you have a few different genuine dumps taken from systems where this
> is needed (i.e. created with native tools, not linux ones) that can be
> used as test data in a test script added to test/shell/ ?
Sorry we don't have. I just used fdisk to create sgi/sun typed partitions.
and did some tests. Do you have any suggestion as for the automatical test?
Thank you very much!

Best,
Liuhua


