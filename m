From: Alasdair G Kergon <agk@redhat.com>
Date: Thu, 5 May 2016 02:58:49 +0100
Subject: [PATCH] dev-type: add support for checking sgi/sun partition table
In-Reply-To: <20160505013823.GA6535@wlh-host.lab.bej.apac.novell.com>
References: <1459317281-15471-1-git-send-email-lwang@suse.com>
	<20160505013823.GA6535@wlh-host.lab.bej.apac.novell.com>
Message-ID: <20160505015849.GB24139@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Thu, May 05, 2016 at 09:38:23AM +0800, Liuhua Wang wrote:
> Would you please review my patch?

Do you have a few different genuine dumps taken from systems where this
is needed (i.e. created with native tools, not linux ones) that can be
used as test data in a test script added to test/shell/ ?

Alasdair


