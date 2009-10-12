From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Mon, 12 Oct 2009 13:42:08 +0200
Subject: [PATCH 06/11] debian/ubuntu: make the device node creation more atomic
In-Reply-To: <20091012100455.GL19397@agk-dp.fab.redhat.com>
References: <8d71f1ff1c7ef3fa6f9c3e193a94aec8251d8407.1255002311.git.fdinitto@redhat.com>
	<e9a3bd65858c5f5ba4e839c7402a5cbd22b475df.1255002311.git.fdinitto@redhat.com>
	<20091008233958.GU3054@agk-dp.fab.redhat.com>
	<1255327871.10932.21.camel@cerberus.int.fabbione.net>
	<20091012100455.GL19397@agk-dp.fab.redhat.com>
Message-ID: <1255347728.10932.55.camel@cerberus.int.fabbione.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, 2009-10-12 at 11:04 +0100, Alasdair G Kergon wrote:
> On Mon, Oct 12, 2009 at 08:11:11AM +0200, Fabio M. Di Nitto wrote:
> > Do you have a reference to the original submission? I can't find it on
> > either lvm-devel or linux-lvm mailing lists.
>  
> Forwarded.  Debian bug 402132.

The old patch had hardcoded temporary file names.

This new one address the problem by using mktemp(3) and also the only
comment you had on the Debian bug.

I think it's safe to pull it in.

Fabio


