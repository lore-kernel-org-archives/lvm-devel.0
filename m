From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Wed, 19 Nov 2014 01:28:46 +0100
Subject: Improvement of manpages clvmd.8 and blkdeactivate.8
In-Reply-To: <1416069988-13208-1-git-send-email-saulery@free.fr>
References: <1416069988-13208-1-git-send-email-saulery@free.fr>
Message-ID: <546BE43E.2080104@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 15.11.2014 v 17:46 saulery at free.fr napsal(a):
>
> Hello,
>
> Here is a much improved version of blkdeactivate.8 clvmd.8 and manpages. I can
> update others in the same way if you're interested.
>

This patch set has been only partially accepted.

We cannot use  .OP groff macro since it's not compatible with older systems
(i.e. RHEL5) which do not have them build in and so far we support very wide
set of system to compile on.

Also we generally document long option with adding  '-x' short cut on the same 
line - which is likely not fully compliant but yet well readable.

Also I'm not convinced removing space in option list leads to better man page 
formatting.

So few changes are different from your patches.

Please supply groff error list (ideally with the way how to reproduce)
so we could easily see if there is a way to be more consistent yet
we could avoid rewriting everything.

We would already have 'generated' man pages - yet noone stepped into this 
field yet.

Idea is - to use 'single' place for options and doc for option and generate 
man pages and command line options from it (since current way of hand writing 
is usually not in the closest touch with source code).

Zdenek


