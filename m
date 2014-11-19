From: Stéphane Aulery <saulery@free.fr>
Date: Wed, 19 Nov 2014 02:43:04 +0100
Subject: Improvement of manpages clvmd.8 and blkdeactivate.8
In-Reply-To: <546BE43E.2080104@redhat.com>
References: <1416069988-13208-1-git-send-email-saulery@free.fr>
	<546BE43E.2080104@redhat.com>
Message-ID: <20141119014304.GA10581@free.fr>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hello Zdenek,

Le mercredi 19 novembre 2014 ? 01:28:46, Zdenek Kabelac a ?crit :
> Dne 15.11.2014 v 17:46 saulery at free.fr napsal(a):
> >
> >Here is a much improved version of blkdeactivate.8 clvmd.8 and manpages. I can
> >update others in the same way if you're interested.
> >
> 
> This patch set has been only partially accepted.
> 
> We cannot use  .OP groff macro since it's not compatible with older systems
> (i.e. RHEL5) which do not have them build in and so far we support very wide
> set of system to compile on.
> 
> Also we generally document long option with adding  '-x' short cut on the
> same line - which is likely not fully compliant but yet well readable.

Ok. I was not aware of this limitation. Can you use the BSD mdoc format?

> 
> Also I'm not convinced removing space in option list leads to better man
> page formatting.

On this point, I do not look for better formatting but explain the options
usage.According to a case, some have a space, others do not. I thought the
text using /daemons/clvmd/clvmd.c (bx example -E).

There is more than one program (I don't for lvm in particular) that mixes
options, with and without space. It's inconsistent and crazy.

> So few changes are different from your patches.

And I'm not upset. It's good for me.

> Please supply groff error list (ideally with the way how to reproduce)
> so we could easily see if there is a way to be more consistent yet
> we could avoid rewriting everything.

You can use this for syntax errors:

$GROFF_ENCODING=utf8 groff -b -ww -z -mandoc mymanpage.8

I don't know any check program for man macros.

For a complete list, see section STYLE GUIDE of "man-pages" manpage.

 * Program name must be in bold ;
 * Citation of options in text must be in bold ;
 * Citation of option arguments in text must be in italic ;
 * Any reference to another man page should be written with the name in bold ;
 * Entries of SEE ALSO section must be sorted by section number, then by name ;
 * Cite short ant long option integrally ;
 * Sort options to accelerate research ;
 * Be clear (and consistent if possible) with the syntax options ;
 * [...]

Then we can argue. I find that these recommendations are generally good.
The most important is the general consistency across all pages and
fidelity to the behavior of programs, of course.

> We would already have 'generated' man pages - yet noone stepped into this
> field yet.
> 
> Idea is - to use 'single' place for options and doc for option and generate
> man pages and command line options from it (since current way of hand
> writing is usually not in the closest touch with source code).

This is a big deal. I do not even know if it's a good idea in the end
because even directly in the code, all the explanations of an option can
not be found in one place. At best it is possible to generate the
overall page structure, but it will still change the rest by hand. It
adds a lot of complexity for not guarantee results.

Another solution is literate programming. I doubt you want to rewrite
all :-))

Alternatively, you can generate pages from a lightweight markup language
for easy maintenance.

Regards,

-- 
St?phane Aulery


