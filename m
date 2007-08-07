From: Alasdair G Kergon <agk@redhat.com>
Date: Tue, 7 Aug 2007 14:47:04 +0100
Subject: stack smash?
In-Reply-To: <871wegcw1q.fsf@rho.meyering.net>
References: <871wegcw1q.fsf@rho.meyering.net>
Message-ID: <20070807134704.GS2064@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Aug 06, 2007 at 09:17:21PM +0200, Jim Meyering wrote:
> Caveat: There may well be code somewhere that ensures ->path_live is so
> much shorter than PATH_MAX that this is a non-issue.  But if that's the
> case, please let me know and instead, I'll add a comment or some sort
> of assertion here to that effect.
 
Can you fix this at source?  i.e. Add a path size restriction when the original
string is read from the config file, after allowing for the maximum permitted
vgname (NAME_LEN) and suffix.

> Assuming this patch is on the right track (yes, I'll test first),
> any preference on where to #define MIN?  

It's sad this has never made it into a standard include file, but there
are numerous instances of it under /usr/include.

How about adopting the linux kernel version of this with its enforced type
checking?

> Obviously, it doesn't belong in this file.
 
Could include in the new util.h?

>  	if (strcmp(slash, vg->name)) {
> +		char new_name[PATH_MAX];

We define all variables at the top of the function.
If there's a strong feeling a variable should be defined locally to a block,
then instead we split the block out into a separate function.

Alasdair
-- 
agk at redhat.com


