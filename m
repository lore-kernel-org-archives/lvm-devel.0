From: Zdenek Kabelac <zkabelac@redhat.com>
Date: Tue, 12 Oct 2010 15:55:48 +0200
Subject: [PATCH] Fix liblvm2cmd.so linking order for --as-needed builds
In-Reply-To: <1283355456.30896.286.camel@yamato.local>
References: <1283355456.30896.286.camel@yamato.local>
Message-ID: <4CB468E4.4080101@redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 1.9.2010 17:37, Diego Elio Petten? napsal(a):
> Hi all,
> 
> I'm attaching a patch that fix the linking of liblvm2cmd.so so that it
> actually links to the libraries it needs... with the original Makefile,
> the linking order is such that ld drops all the libraries, linking only
> libc at the end... this in turn will cause undefined references to floor
> when the library is loaded in (see http://bugs.gentoo.org/335205 for
> reference).

The last occurrence of  CLDWHOLEARCHIVE in tools/Makefile.in seems to be
dropped by this Alasdair's commit:

Author: Alasdair Kergon <agk@redhat.com>
Date:   Thu Feb 2 19:16:47 2006 +0000

Which seems to in somewhat history.

So this patch doesn't look like upstream related - rather some local 'gentoo'
cooking patch ?   Is gentoo doing their own build rules?

If the upstream still has any linking problem - please report problems/patches
against upstream CVS/git repository.


Zdenek


