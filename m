From: Zdenek Kabelac <zdenek.kabelac@gmail.com>
Date: Wed, 19 Nov 2014 08:42:33 +0100
Subject: Improvement of manpages clvmd.8 and blkdeactivate.8
In-Reply-To: <20141119014304.GA10581@free.fr>
References: <1416069988-13208-1-git-send-email-saulery@free.fr>	<546BE43E.2080104@redhat.com>
	<20141119014304.GA10581@free.fr>
Message-ID: <546C49E9.6020900@gmail.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Dne 19.11.2014 v 02:43 St?phane Aulery napsal(a):
> Hello Zdenek,
>
> Le mercredi 19 novembre 2014 ? 01:28:46, Zdenek Kabelac a ?crit :
>> Dne 15.11.2014 v 17:46 saulery at free.fr napsal(a):
>>>
>>> Here is a much improved version of blkdeactivate.8 clvmd.8 and manpages. I can
>>> update others in the same way if you're interested.
>>>
>>
>> This patch set has been only partially accepted.
>>
>> We cannot use  .OP groff macro since it's not compatible with older systems
>> (i.e. RHEL5) which do not have them build in and so far we support very wide
>> set of system to compile on.
>>
>> Also we generally document long option with adding  '-x' short cut on the
>> same line - which is likely not fully compliant but yet well readable.
>
> Ok. I was not aware of this limitation. Can you use the BSD mdoc format?

Maybe there is a way how to provide 'embeded' macro definition with lvm2 code 
base - so if they are not available in the system - built-in definition from 
lvm2 would be user ? - something like .m4 macros fro configure  - though I'm
surely not man-page/groff expert here.

>
> You can use this for syntax errors:
>
> $GROFF_ENCODING=utf8 groff -b -ww -z -mandoc mymanpage.8

I'll check

>
> I don't know any check program for man macros.
>
> For a complete list, see section STYLE GUIDE of "man-pages" manpage.
>
>   * Program name must be in bold ;
>   * Citation of options in text must be in bold ;
>   * Citation of option arguments in text must be in italic ;
>   * Any reference to another man page should be written with the name in bold ;
>   * Entries of SEE ALSO section must be sorted by section number, then by name ;
>   * Cite short ant long option integrally ;
>   * Sort options to accelerate research ;
>   * Be clear (and consistent if possible) with the syntax options ;
>   * [...]

All those are mostly known and agreed, but there are no hands to change them 
all and moreover even fix them.

> Then we can argue. I find that these recommendations are generally good.
> The most important is the general consistency across all pages and
> fidelity to the behavior of programs, of course.
>
>> We would already have 'generated' man pages - yet noone stepped into this
>> field yet.
>>
>> Idea is - to use 'single' place for options and doc for option and generate
>> man pages and command line options from it (since current way of hand
>> writing is usually not in the closest touch with source code).
>
> This is a big deal. I do not even know if it's a good idea in the end
> because even directly in the code, all the explanations of an option can
> not be found in one place. At best it is possible to generate the
> overall page structure, but it will still change the rest by hand. It
> adds a lot of complexity for not guarantee results.
>
> Another solution is literate programming. I doubt you want to rewrite
> all :-))

The problem here is - we try to keep 'meaning' of option consistent across 
commands, but it's often forgotten in which commands the individual option
are used - so if the description for an option is fixed in one place, it then 
still appear in some broken form in other command.  Also users tend to be 
often confused where 'common' options are only described in 'man lvm(8)' and 
they are missing in the command itself.

So having a single place for option description would make things much easier 
to maintain.

Maybe there is already some solution for this used in some other projects ?

Regards

Zdenek


