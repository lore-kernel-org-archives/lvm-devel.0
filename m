From: Alasdair G Kergon <agk@redhat.com>
Date: Fri, 23 Apr 2010 00:59:31 +0100
Subject: Using glibc regex
In-Reply-To: <4BCDB504.2080104@redhat.com>
References: <4BCDB504.2080104@redhat.com>
Message-ID: <20100422235931.GD23791@agk-dp.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

On Tue, Apr 20, 2010 at 04:07:00PM +0200, Zdenek Kabelac wrote:
> This patch replaces internal  dm_regex and uses  glibc regex routines so we
> achieve better performance for things like hundreds patterns.
 
How about getting 3 versions of this code into the tree in parallel
for a while?

   1) current cvs with optimiser
   2) new ejt dfa changes
   3) glibc regex

Put the bits that differ into separate files, keeping the tree reasonably
clean but not worrying too much about refactoring to avoid code
duplication - eventually two out of the three will be thrown away.

When we want to match a string, test against all 3 engines and if the
results differ, report the details and take the majority answer.
(A standard configure/lvm.conf setting could control which of the 3 are used.)
We could generate timing statistics too for all three (extend
lib/misc/timestamp,c) dumped when the process exits.

With all three enabled by default, the additional overhead shouldn't matter for
most people - it should be absorbed within the speedups we've recently
obtained so the sum of the 3 ought to still run faster than the 1 did
before.

Alasdair


