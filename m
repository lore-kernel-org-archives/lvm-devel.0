From: Bastian Blank <bastian@waldi.eu.org>
Date: Fri, 9 Oct 2009 17:01:48 +0200
Subject: [PATCH 11/11] debian: drop concept of OWNER/GROUP and let install do it's job for permissions
In-Reply-To: <20091009000134.GY3054@agk-dp.fab.redhat.com>
References: <8d71f1ff1c7ef3fa6f9c3e193a94aec8251d8407.1255002311.git.fdinitto@redhat.com>
	<f3faad08f59b098ed7ae0019db660d0e15797cbe.1255002311.git.fdinitto@redhat.com>
	<20091009000134.GY3054@agk-dp.fab.redhat.com>
Message-ID: <20091009150148.GC6904@wavehammer.waldi.eu.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, Oct 09, 2009 at 01:01:34AM +0100, Alasdair G Kergon wrote:
> On Thu, Oct 08, 2009 at 02:49:18PM +0200, Fabio M. Di Nitto wrote:
> > remove owner and group definitions and install anything writable as mendated
> > by the debian policy
> --with-user= and --with-group= should already handle the owner and group
> (i.e. set them to blank like we do in RHEL/Fedora)

So noone uses that functionality. Why is it there and why is it used by
default? Every system where the defaults used by install (maybe *BSD)
have there own mechanism to solve this.

Bastian

-- 
Conquest is easy. Control is not.
		-- Kirk, "Mirror, Mirror", stardate unknown


