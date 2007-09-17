From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 17 Sep 2007 19:15:51 +0100
Subject: RFC: testing framework
In-Reply-To: <87ejgxcxpn.fsf@rho.meyering.net>
References: <87y7f9krex.fsf@rho.meyering.net> <87ejgxcxpn.fsf@rho.meyering.net>
Message-ID: <20070917181551.GK18444@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Mon, Sep 17, 2007 at 01:56:04PM +0200, Jim Meyering wrote:
> At Alasdair's private suggestion, I've adjusted my patch to use
> the existing test/ directory instead.
> 
> If he agrees, I'll move the preexisting (unused) test/* subdirs
> "down" into a new test/unit/ dir, or into a new, top-level unit-test/
> directory.  But that will be a separate delta.

Given the limitations of CVS, I've done this within the repository so as
to preserve the file history.  Repository users should remove their
'test' directory and check out 'test' and 'old-tests' afresh.
(I'm leaving 'old-tests' for reference but I stopped maintaining it some
time ago.  Any new tests should be done within the new infrastructure.)

Alasdair
-- 
agk at redhat.com


