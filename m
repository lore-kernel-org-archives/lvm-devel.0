From: Jim Meyering <jim@meyering.net>
Date: Mon, 06 Aug 2007 17:55:34 +0200
Subject: write-to-stdout failure not detected
Message-ID: <87ir7sd5e1.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Last week I spotted a problem with all LVM stdout-writing tools: e.g.,
vgs > /dev/full mistakenly exits successfully (should exit nonzero
with a diagnostic reflecting the write that fails with ENOSPC).
Unfortunately, it's not easy to fix.  The offending unchecked "fflush"
is buried in a "void" function (in lib/log/log.c), so fixing it
properly would require interface changes.

On one hand, there are probably scripts out there that write lvm-related
output to a file, and then read the file, parsing the result, so it'd be
good to fix this.  Currently, when writing to a full disk or getting an
I/O error, lvm tools will simply produce empty or corrupted output and
exit successfully, so there's no way for a script to detect the failure.

On the other hand, failure is pretty unlikely (ENOSPC and EIO are the
usual culprits), so it may not be worth much effort.  But since this is
LVM, the cost of failure may be quite high...


