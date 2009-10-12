From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 12 Oct 2009 11:03:59 +0100
Subject: [PATCH 01/11] debian: fix library search path in example.conf
In-Reply-To: <1255320125.10932.17.camel@cerberus.int.fabbione.net>
References: <1255002904-6226-1-git-send-email-fdinitto@redhat.com>
	<8d71f1ff1c7ef3fa6f9c3e193a94aec8251d8407.1255002311.git.fdinitto@redhat.com>
	<20091008232725.GP3054@agk-dp.fab.redhat.com>
	<1255280941.10932.6.camel@cerberus.int.fabbione.net>
	<20091011202347.GD21726@wavehammer.waldi.eu.org>
	<1255320125.10932.17.camel@cerberus.int.fabbione.net>
Message-ID: <20091012100359.GK19397@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Oct 12, 2009 at 06:02:05AM +0200, Fabio M. Di Nitto wrote:
> On Sun, 2009-10-11 at 22:23 +0200, Bastian Blank wrote:
> > Its currently unused. The cluster locking lib was the only used external
> > lib.
 
> Alasdair, given that cluster locking lib is gone, do we have a use case
> to keep this option configurable? 

It's used for all lvm2 external libraries and needs to stay.  The
commented-out example is only worth making configurable if people are
actually installing libraries into private directories (and arguably it
should then be hard-coded into the source too).

We only stopped building the cluster locking library externally on Red
Hat distributions because of some complexities of the Red Hat build
system.  If they get resolved (as I hope they will be with RHEL6) then
we will probably reinstate it.  

Alasdair


