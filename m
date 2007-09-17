From: Alasdair G Kergon <agk@redhat.com>
Date: Mon, 17 Sep 2007 22:45:50 +0100
Subject: RFC: testing framework
In-Reply-To: <87sl5d9flu.fsf@rho.meyering.net>
References: <87y7f9krex.fsf@rho.meyering.net> <87ejgxcxpn.fsf@rho.meyering.net>
	<20070917190424.GL18444@agk.fab.redhat.com>
	<87sl5d9flu.fsf@rho.meyering.net>
Message-ID: <20070917214550.GX18444@agk.fab.redhat.com>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Yes, check in what you've got so far.

Make sure there's a copyright/licence line in each file - see
existing Makefiles etc.  

  # This file is part of the LVM2.

Oops - there's an extra "the" in a handful of files!

For the numbering, 1000 between each item seems overkill - we'll soon want more than 10
top-level categories.

Perhaps 5 digits 00100  00200 etc.
Or 00100 00110 00120 etc.

Or place in subdirectories - an lvcreate subdir for lvcreate tests etc.
and have the numbering within lvcreate
ie they report as lvcreate_0010  lvcreate_0020 etc.

Alasdair
-- 
agk at redhat.com


