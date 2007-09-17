From: Jim Meyering <jim@meyering.net>
Date: Mon, 17 Sep 2007 14:55:42 +0200
Subject: proposed change: don't spew all --help output for every usage error
Message-ID: <878x75cuy9.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Any time I misuse an option or use invalid command syntax,
a tool like lvcreate gives a diagnostic saying what went wrong,
and follows it with almost 50 lines of usage information.
That's almost enough to make the important, one-line diagnostic,
scroll beyond the top of my terminal emulator window.

I propose to change this so that upon error, users do still
see the relevant one-line diagnostic (of course), but rather than
the voluminous and obscuring --help output, the tool would simply
output one more line:

  Try `lvcreate --help' for more information.

Also, for all tools, --help output currently goes to stderr.
I will be happy to submit another patch to make the LVM tools
work more like most of the other unix/gnu tools that take --help
as an option: they print --help output to standard output.
That makes it easier for novices to grep through the help output
or to send it through a pager or other pipe.
Besides, when there is no "error", why write to stderr?

FWIW, I've just run into this while writing tests for lvcreate.
I wanted to compare expected error output with actual, but embedding
all 47 "expected" lines in the test script seems excessive.  Also,
when I looked at the actual output, at first I didn't even see the
real diagnostic I'd been expecting, buried amid all the --help output.
So, if *I*, who was expecting a particular diagnostic, nearly miss it,
the average user may not look as hard, and end up having to figure out
the hard way what they did wrong.

So, actually there are two proposals:

  - Print "Try `$cmd --help' for more information." instead of all --help
    output upon bogus command line usage. (still to stderr, of course)

  - Print --help output to stdout, not stderr.


