From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Fri, 18 Jun 2010 11:48:18 +0200
Subject: Patch for adding --resize to manpage
In-Reply-To: <98BA4E4E-36F1-4A2F-9F1B-326C85F3BFE0@redhat.com>
References: <4C0E4304.9030601@redhat.com>
	<98BA4E4E-36F1-4A2F-9F1B-326C85F3BFE0@redhat.com>
Message-ID: <4C1B40E2.6020606@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 18.6.2010 00:10, Jonathan Brassow napsal(a):
> Under lvextend/'--force', s/without any question/without any questions/.
>
> Under lvextend/'--resizefs', The sentence about 'fsadm' seems to imply that it
> is necessary in addition to the argument. Is this the case? If not, perhaps we
> could say something like, "fsadm can be used to resize a filesystem separately
> if this option is not used."


It works rather this way:

lvresize calculates new blocksize from command line options and
- resizes LV and execs fsadm for fs resize (lvextend)
- or execs fsadm for fs shrink and then reduces LV (lvreduce)

It will not work without fsadm as the lvresize command does not know anything 
about filesystems and their utilities for its resizing.

The other way around is - to use only  fsadm - which will use lvresize.
It should have easier syntax for user - on the other hand - doesn't handle 
given sizes  - i.e.  1.5GB (float numbers) are not yet supported by this tool 
and user needs to use 1500M.

Zdenek


