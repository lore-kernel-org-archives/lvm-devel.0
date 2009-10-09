From: Bastian Blank <bastian@waldi.eu.org>
Date: Fri, 9 Oct 2009 16:58:49 +0200
Subject: [PATCH 08/11] debian: use selinux pkgconfig info instead of hardcoding
In-Reply-To: <20091008234450.GW3054@agk-dp.fab.redhat.com>
References: <8d71f1ff1c7ef3fa6f9c3e193a94aec8251d8407.1255002311.git.fdinitto@redhat.com>
	<afcb9c9c64ef9416639b7c508add1e519a62fbb7.1255002311.git.fdinitto@redhat.com>
	<20091008234450.GW3054@agk-dp.fab.redhat.com>
Message-ID: <20091009145849.GA6904@wavehammer.waldi.eu.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Oct 09, 2009 at 12:44:50AM +0100, Alasdair G Kergon wrote:
> On Thu, Oct 08, 2009 at 02:49:15PM +0200, Fabio M. Di Nitto wrote:
> > use selinux pkgconfig file instead of hardcoding the contents
> I don't think this patch goes far enough...

This is the external view.

> The build should be using the pc file too (if present), as we now do for clvmd!

This is the internal view. This are different parts.

Bastian

-- 
Those who hate and fight must stop themselves -- otherwise it is not stopped.
		-- Spock, "Day of the Dove", stardate unknown


