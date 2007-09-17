From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 17 Sep 2007 20:09:50 +0100
Subject: Re: proposed change: don't spew all --help output for every usage error
In-Reply-To: <878x75cuy9.fsf@rho.meyering.net>
References: <878x75cuy9.fsf@rho.meyering.net>
Message-ID: <20070917190950.GM18444@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Sep 17, 2007 at 02:55:42PM +0200, Jim Meyering wrote:
> Any time I misuse an option or use invalid command syntax,
> a tool like lvcreate gives a diagnostic saying what went wrong,
> and follows it with almost 50 lines of usage information.

An approach inherited from LVM1.  Yes, let's change it.

>   Try `lvcreate --help' for more information.
 
'Use' or 'Run' rather than 'Try'?
'more information': currently it's just the command syntax we give.
-h also works.

> as an option: they print --help output to standard output.

stderr is sensible today, because these are error messages.
But if they are only going to appear when you explicitly ask for them
with -h then stdout makes sense.

>   - Print "Try `$cmd --help' for more information." instead of all --help
>     output upon bogus command line usage. (still to stderr, of course)

So yes, but the wording should be improved.
 
>   - Print --help output to stdout, not stderr.

Yes, after the first change.

Alasdair
-- 
agk at redhat.com


