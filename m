From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Mon, 12 Oct 2009 11:30:30 +0200
Subject: [PATCH 11/11] debian: drop concept of OWNER/GROUP and let install do it's job for permissions
In-Reply-To: <20091009162914.GH3054@agk-dp.fab.redhat.com>
References: <8d71f1ff1c7ef3fa6f9c3e193a94aec8251d8407.1255002311.git.fdinitto@redhat.com>
	<f3faad08f59b098ed7ae0019db660d0e15797cbe.1255002311.git.fdinitto@redhat.com>
	<20091009000134.GY3054@agk-dp.fab.redhat.com>
	<20091009150148.GC6904@wavehammer.waldi.eu.org>
	<20091009162914.GH3054@agk-dp.fab.redhat.com>
Message-ID: <1255339830.10932.52.camel@cerberus.int.fabbione.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, 2009-10-09 at 17:29 +0100, Alasdair G Kergon wrote:
> On Fri, Oct 09, 2009 at 05:01:48PM +0200, Bastian Blank wrote:
> > why is it used by
> > default? 
> 
> I'm open to changing that default.

Let's split this patch in 2:

1) OWNER/GROUP defaults, I'd say we should change the default to "".

Both Fedora and Debian drops it, all packaging systems I have seen
around expect to build/install as user and then convert to proper
owner/group as mandate by distribution policies.
I don't see a real good reason to force a default, and as upstream we
would still allow override via configure options.

2) install permissions.

I have more or less the same comment as #1. All distribution packaging
do a permission cleanup after "make install" by forcing distribution
policies.

Unless there is a real security concern behind it, I think we can
delegate such tasks to install and packagers.

The Debian defaults seem sane enough to me, but I am open to
suggestions.

Making it a configurable set of options seems a bit overkilling.

Fabio


