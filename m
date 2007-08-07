From: Jim Meyering <jim@meyering.net>
Date: Tue, 07 Aug 2007 23:51:18 +0200
Subject: stack smash?
In-Reply-To: <20070807134704.GS2064@agk.fab.redhat.com> (Alasdair G. Kergon's
	message of "Tue\, 7 Aug 2007 14\:47\:04 +0100")
References: <871wegcw1q.fsf@rho.meyering.net>
	<20070807134704.GS2064@agk.fab.redhat.com>
Message-ID: <87wsw78149.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon <agk@redhat.com> wrote:
> On Mon, Aug 06, 2007 at 09:17:21PM +0200, Jim Meyering wrote:
>> Caveat: There may well be code somewhere that ensures ->path_live is so
>> much shorter than PATH_MAX that this is a non-issue.  But if that's the
>> case, please let me know and instead, I'll add a comment or some sort
>> of assertion here to that effect.
>
> Can you fix this at source?  i.e. Add a path size restriction when the original
> string is read from the config file, after allowing for the maximum permitted
> vgname (NAME_LEN) and suffix.

I took a quick look and think I saw a command-line source, too.
IMHO, even if you can guarantee something like this at the source,
it's good to have a run-time check right before the strcpy, since
it's so "distant".  Besides, some systems (Hurd) don't even define
PATH_MAX (or make it very large), so it's better to minimize use
of that macro.  Also, isn't it overkill to limit all names to a
length of < PATH_MAX - NAME_LEN - suffix_len, just to avoid the
length check when renaming?

>> Assuming this patch is on the right track (yes, I'll test first),
>> any preference on where to #define MIN?
>
> It's sad this has never made it into a standard include file, but there
> are numerous instances of it under /usr/include.
>
> How about adopting the linux kernel version of this with its enforced type
> checking?

Sure.

>> Obviously, it doesn't belong in this file.
>
> Could include in the new util.h?
>
>>  	if (strcmp(slash, vg->name)) {
>> +		char new_name[PATH_MAX];
>
> We define all variables at the top of the function.

I think you did mention that LVM and DM have this convention.
I find the contrary (scope as tightly as possible) makes code more
readable and more robust.  If you would consider relaxing this
restriction, let me know: I'll be happy to provide justification.
[BTW, what's the motivation for it? ]

I believe strongly enough in the benefit of this approach that (in
coreutils) I've begun using the c99 feature that allows declarations
after statements, and maintaining a c99-to-c89 patch set for those
who are unable to compile with a c99-compliant compiler.  However,
note that I wouldn't propose going that far here.  Simply allowing
c*8*9 scoped declarations provides most of the benefits without the
portability/maintenance hassle.

> If there's a strong feeling a variable should be defined locally to a block,
> then instead we split the block out into a separate function.


