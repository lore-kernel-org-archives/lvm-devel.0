From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Sun, 11 Oct 2009 19:09:01 +0200
Subject: [PATCH 01/11] debian: fix library search path in example.conf
In-Reply-To: <20091008232725.GP3054@agk-dp.fab.redhat.com>
References: <1255002904-6226-1-git-send-email-fdinitto@redhat.com>
	<8d71f1ff1c7ef3fa6f9c3e193a94aec8251d8407.1255002311.git.fdinitto@redhat.com>
	<20091008232725.GP3054@agk-dp.fab.redhat.com>
Message-ID: <1255280941.10932.6.camel@cerberus.int.fabbione.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Fri, 2009-10-09 at 00:27 +0100, Alasdair G Kergon wrote:
> On Thu, Oct 08, 2009 at 01:54:54PM +0200, Fabio M. Di Nitto wrote:
> > this patch is debian specific and sets the library search path
> > to /lib/lvm2 to avoid cluttering /lib
>  
> Add configure parm for this and generate example.conf from template?
> 
> In fact, it would be useful to know the current 'configure' line that
> Debian uses.

I think this patch is bogus even in Debian.

After some investigation "/lib/lvm2/" used to be the default for Debian
up to version 2.00.32-1 and then it was reverted to upstream default to
fix bug http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=287042

Other than the example config file there are no traces of /lib/lvm2
anywhere in the package.

I attached debian/rules anyway as it could be helpful for other patches.

Fabio
-------------- next part --------------
A non-text attachment was scrubbed...
Name: rules
Type: text/x-makefile
Size: 9017 bytes
Desc: not available
URL: <http://listman.redhat.com/archives/lvm-devel/attachments/20091011/542b5fd9/attachment.bin>
