From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 12 Oct 2009 11:14:57 +0100
Subject: [PATCH 11/11] debian: drop concept of OWNER/GROUP and let install do it's job for permissions
In-Reply-To: <1255339830.10932.52.camel@cerberus.int.fabbione.net>
References: <8d71f1ff1c7ef3fa6f9c3e193a94aec8251d8407.1255002311.git.fdinitto@redhat.com>
	<f3faad08f59b098ed7ae0019db660d0e15797cbe.1255002311.git.fdinitto@redhat.com>
	<20091009000134.GY3054@agk-dp.fab.redhat.com>
	<20091009150148.GC6904@wavehammer.waldi.eu.org>
	<20091009162914.GH3054@agk-dp.fab.redhat.com>
	<1255339830.10932.52.camel@cerberus.int.fabbione.net>
Message-ID: <20091012101457.GM19397@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Oct 12, 2009 at 11:30:30AM +0200, Fabio M. Di Nitto wrote:
> 1) OWNER/GROUP defaults, I'd say we should change the default to "".

Yes.
 
> 2) install permissions.
> 
> I have more or less the same comment as #1. All distribution packaging
> do a permission cleanup after "make install" by forcing distribution
> policies.
> 
> Unless there is a real security concern behind it, I think we can
> delegate such tasks to install and packagers.
> 
> Making it a configurable set of options seems a bit overkilling.
 
If I run this outside a packaging framework I still need the permissions
to be set.

So then leave this unchanged, and there is no point in Debian or any other
packaging system removing the existing permission setting because the packaging
system is going to override it afterwards anyway.

Alasdair


