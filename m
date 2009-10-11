From: Bastian Blank <bastian@waldi.eu.org>
Date: Sun, 11 Oct 2009 22:20:33 +0200
Subject: [PATCH 04/11] debian: fix implicit pointer
In-Reply-To: <1255282176.10932.13.camel@cerberus.int.fabbione.net>
References: <8d71f1ff1c7ef3fa6f9c3e193a94aec8251d8407.1255002311.git.fdinitto@redhat.com>
	<3b7fddbbcca36451e4b8e3617ab54c6e5839877a.1255002311.git.fdinitto@redhat.com>
	<20091008233412.GS3054@agk-dp.fab.redhat.com>
	<1255282176.10932.13.camel@cerberus.int.fabbione.net>
Message-ID: <20091011202033.GC21726@wavehammer.waldi.eu.org>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Sun, Oct 11, 2009 at 07:29:36PM +0200, Fabio M. Di Nitto wrote:
> Bastian, I'd like to investigate this further. Can you please me provide
> me with details of your test machine? Debian SID? x86? x86_64? tool
> chain version? etc.

http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=516867
https://buildd.debian.org/fetch.cgi?&pkg=lvm2&ver=2.02.44-1&arch=ia64&stamp=1235444991&file=log

Actually configure was not able to find rl_completion_matches but it was
usable.

Bastian

-- 
Warp 7 -- It's a law we can live with.


