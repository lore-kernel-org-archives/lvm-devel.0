From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 17 Sep 2007 20:49:06 +0100
Subject: test/t1000-lvcreate-usage.sh: exercise lvcreate
In-Reply-To: <87vea99j54.fsf@rho.meyering.net>
References: <873axdcpzg.fsf@rho.meyering.net>
	<20070917192012.GN18444@agk.fab.redhat.com>
	<87vea99j54.fsf@rho.meyering.net>
Message-ID: <20070917194906.GQ18444@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

> > [I noticed a '>/dev/null' earlier that ought
> > to disappear:-) ]
> If you mean the one in t1000*'s cleanup_ function, then
> I'd rather not remove it.  

What I mean is no output should be discarded anywhere.  It should all
be captured into log files in case someone wants to refer to it.

Alasdair
-- 
agk at redhat.com


