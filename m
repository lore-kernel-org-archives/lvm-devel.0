From: Jim Meyering <jim@meyering.net>
Date: Fri, 21 Sep 2007 13:30:03 +0200
Subject: revised error output: Run ... --help for more information
In-Reply-To: <20070917190950.GM18444@agk.fab.redhat.com> (Alasdair G. Kergon's
	message of "Mon, 17 Sep 2007 20:09:50 +0100")
References: <878x75cuy9.fsf@rho.meyering.net>
	<20070917190950.GM18444@agk.fab.redhat.com>
Message-ID: <877imkfe84.fsf_-_@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon <agk@redhat.com> wrote:
> On Mon, Sep 17, 2007 at 02:55:42PM +0200, Jim Meyering wrote:
>> Any time I misuse an option or use invalid command syntax,
>> a tool like lvcreate gives a diagnostic saying what went wrong,
>> and follows it with almost 50 lines of usage information.
>
> An approach inherited from LVM1.  Yes, let's change it.
>
>>   Try `lvcreate --help' for more information.
>
> 'Use' or 'Run' rather than 'Try'?
> 'more information': currently it's just the command syntax we give.
> -h also works.
>
>> as an option: they print --help output to standard output.
>
> stderr is sensible today, because these are error messages.
> But if they are only going to appear when you explicitly ask for them
> with -h then stdout makes sense.
>
>>   - Print "Try `$cmd --help' for more information." instead of all --help
>>     output upon bogus command line usage. (still to stderr, of course)
>
> So yes, but the wording should be improved.
>
>>   - Print --help output to stdout, not stderr.
>
> Yes, after the first change.

Good!

I implemented the above (step 1), and now see this:

    $ ./lvchange
      Need 1 or more of -a, -C, -j, -m, -M, -p, -r, --resync, --refresh, --alloc, --addtag, --deltag or --monitor
      lvchange: Run `lvchange --help' for more information.

    [Exit 3]


Note the lack of a command name on the "real" diagnostic line.
And the fact that it appears twice on the Run --help line.

I want to reverse that, so the command name appears where it's more useful
(on the line with the real diagnostic), and not on the Run --help line:

    $ ./lvchange
      lvchange: Need 1 or more of -a, -C, -j, -m, -M, -p, -r, --resync, --refresh, --alloc, --addtag, --deltag or --monitor
      Run `lvchange --help' for more information.

    [Exit 3]

This has two advantages:

  * primarily: when an lvm command fails within a script run by a script
  invoked by another, it's far easier to determine which program emitted any
  given diagnostic when the command's name is right there on the same line.

  * consistency: nearly every other Unix command-line program prints
  diagnostics like this: printf_style ("%s: %s", command_name, diagnostic)

The consistency argument is non-negligible.  I've used tools that
search for diagnostics using a regular expression like /^\w+:/.
They wouldn't detect LVM diagnostics the way they're formatted, now.


