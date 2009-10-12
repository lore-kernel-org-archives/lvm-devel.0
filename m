From: Fabio M. Di Nitto <fdinitto@redhat.com>
Date: Mon, 12 Oct 2009 10:07:54 +0200
Subject: [PATCH 04/11] debian: fix implicit pointer
In-Reply-To: <20091011202033.GC21726@wavehammer.waldi.eu.org>
References: <8d71f1ff1c7ef3fa6f9c3e193a94aec8251d8407.1255002311.git.fdinitto@redhat.com>
	<3b7fddbbcca36451e4b8e3617ab54c6e5839877a.1255002311.git.fdinitto@redhat.com>
	<20091008233412.GS3054@agk-dp.fab.redhat.com>
	<1255282176.10932.13.camel@cerberus.int.fabbione.net>
	<20091011202033.GC21726@wavehammer.waldi.eu.org>
Message-ID: <1255334874.10932.25.camel@cerberus.int.fabbione.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sun, 2009-10-11 at 22:20 +0200, Bastian Blank wrote:
> On Sun, Oct 11, 2009 at 07:29:36PM +0200, Fabio M. Di Nitto wrote:
> > Bastian, I'd like to investigate this further. Can you please me provide
> > me with details of your test machine? Debian SID? x86? x86_64? tool
> > chain version? etc.
> 
> http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=516867
> https://buildd.debian.org/fetch.cgi?&pkg=lvm2&ver=2.02.44-1&arch=ia64&stamp=1235444991&file=log
> 
> Actually configure was not able to find rl_completion_matches but it was
> usable.

This seems to be a bug introduced by Debian autoreconf.

Using upstream configure:

configure:13440: checking for rl_completion_matches
configure:13496: gcc -o conftest    -Wl,--export-dynamic conftest.c
-lreadline -lrt -lselinux -lsepol  -ldl -lncurses  >&5
configure:13503: $? = 0
configure:13525: result: yes

Using Debian regenerated configure:

configure:8220: checking for rl_completion_matches
configure:8220: gcc -o conftest -g -O2   conftest.c -ldl  >&5
/tmp/ccUvvocx.o: In function `main':
/root/lvm2-2.02.53/debian/build/build-deb/conftest.c:142: undefined
reference to
 `rl_completion_matches'
collect2: ld returned 1 exit status
configure:8220: $? = 1

Maybe it's a regression introduced by autoconf 2.64 that's not available
in Fedora yet.

Fabio


