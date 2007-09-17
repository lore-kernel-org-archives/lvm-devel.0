From: Jim Meyering <jim@meyering.net>
Date: Mon, 17 Sep 2007 21:39:03 +0200
Subject: test/t1000-lvcreate-usage.sh: exercise lvcreate
In-Reply-To: <20070917192012.GN18444@agk.fab.redhat.com> (Alasdair G. Kergon's
	message of "Mon, 17 Sep 2007 20:20:12 +0100")
References: <873axdcpzg.fsf@rho.meyering.net>
	<20070917192012.GN18444@agk.fab.redhat.com>
Message-ID: <87vea99j54.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Alasdair G Kergon <agk@redhat.com> wrote:

> On Mon, Sep 17, 2007 at 04:42:59PM +0200, Jim Meyering wrote:
>> When I run the new test by itself, it does this:
>>     # cd test && ./t1000-lvcreate-usage.sh
>>     *   ok 1: set up temp files, loopback devices, PVs, and a VG
>>     *   ok 2: lvcreate w/negative stripesize must fail
>>     *   ok 3: lvcreate w/too-large stripesize must fail
>>     *   ok 4: lvcreate w/single stripe succeeds with diagnostics to stdout
>>     *   ok 5: lvcreate w/no stripe size succeeds with diagnostics to stdout
>>     *   ok 6: lvcreate w/invalid number of stripes must fail
>>     *   ok 7: lvcreate w/invalid stripe size must fail
>>     * passed all 7 test(s)
>
> Can you make that easier to parse?

The idea is that you don't bother to parse it unless something fails :)
But see proposed rewordings below.

> Should every test have a reference number (perhaps derived from its

All of those tests come from the same file: t1000-lvcreate-usage.
Currently, I have these files:

  $ ls -1 t[0-9]*.sh
  t0000-basic.sh*
  t1000-lvcreate-usage.sh*
  t3000-lvcreate-pvtags.sh*
  t4000-pv-range-overflow.sh*

The numbers are pretty arbitrary, now.
Ideally, you'd put simplest tests early and ones that rely on
more and more functionality/tools later.

> filename?) that is not going to change and appears on the output line?

IMHO, the combination of the file name, t1000-lvcreate-usage,
and the textual "title" of each test within that file is sufficient
to identify it.

> Should each test belong to a defined category, e.g. 'lvcreate' above.
> What role do the *s serve?  Would a wider range of characters make
> the output more readable?

The output format is from that of git's tests.

> Can the version of the test also appear in the test logs along with
> complete command output?

If you want more output, you can run the test with --debug --verbose.
Or set those options in test/Makefile.in.  This is the first line of
that file:

    #TEST_OPTS=--verbose --debug

> [I noticed a '>/dev/null' earlier that ought
> to disappear:-) ]

If you mean the one in t1000*'s cleanup_ function, then
I'd rather not remove it.  Otherwise, currently you'd see
this at the end of the test:

    0 logical volume(s) in volume group "t1000-test-vg-11070" now active
    Volume group "t1000-test-vg-11070" successfully removed

> 'ok' with 'must fail' is misleading - try inverting the descriptions
> e.g. 'rejects negative stripesizes'  (plural as I'd assume a range of
> values are being tested each time)

How about these rewordings:

    ./t1000-lvcreate-usage.sh
    *   ok 1: set up temp files, loopback devices, PVs, and a VG
    *   ok 2: lvcreate rejects a negative stripesize
    *   ok 3: lvcreate rejects a too-large stripesize
    *   ok 4: lvcreate w/single stripe succeeds with diagnostics to stdout
    *   ok 5: lvcreate w/no stripe size succeeds with diagnostics to stdout
    *   ok 6: lvcreate rejects an invalid number of stripes
    *   ok 7: lvcreate rejects an invalid stripe size


