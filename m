From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 17 Sep 2007 20:20:12 +0100
Subject: test/t1000-lvcreate-usage.sh: exercise lvcreate
In-Reply-To: <873axdcpzg.fsf@rho.meyering.net>
References: <873axdcpzg.fsf@rho.meyering.net>
Message-ID: <20070917192012.GN18444@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Sep 17, 2007 at 04:42:59PM +0200, Jim Meyering wrote:
> When I run the new test by itself, it does this:
>     # cd test && ./t1000-lvcreate-usage.sh
>     *   ok 1: set up temp files, loopback devices, PVs, and a VG
>     *   ok 2: lvcreate w/negative stripesize must fail
>     *   ok 3: lvcreate w/too-large stripesize must fail
>     *   ok 4: lvcreate w/single stripe succeeds with diagnostics to stdout
>     *   ok 5: lvcreate w/no stripe size succeeds with diagnostics to stdout
>     *   ok 6: lvcreate w/invalid number of stripes must fail
>     *   ok 7: lvcreate w/invalid stripe size must fail
>     * passed all 7 test(s)
 
Can you make that easier to parse?
Should every test have a reference number (perhaps derived from its
filename?) that is not going to change and appears on the output line?
Should each test belong to a defined category, e.g. 'lvcreate' above.
What role do the *s serve?  Would a wider range of characters make
the output more readable?
Can the version of the test also appear in the test logs along with
complete command output?  [I noticed a '>/dev/null' earlier that ought
to disappear:-) ]

'ok' with 'must fail' is misleading - try inverting the descriptions
e.g. 'rejects negative stripesizes'  (plural as I'd assume a range of
values are being tested each time)

Alasdair
-- 
agk at redhat.com


