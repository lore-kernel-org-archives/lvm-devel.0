From: Jim Meyering <jim@meyering.net>
Date: Fri, 21 Sep 2007 12:34:31 +0200
Subject: removing trailing blanks in lvm and dm
Message-ID: <87d4wcfgso.fsf@rho.meyering.net>
List-Id: <lvm-devel.redhat.com>
To: lvm-devel@redhat.com
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit

Hi Alasdair,

I'd like to remove all trailing blanks from lvm and dm.

I want to do this because I've been burned by them upon occasion and
so, now I use a mode in emacs and in vi that highlights them, as well
as another that asks me whether to remove them whenever I write a file
in emacs.  FWIW, a trailing space in a Makefile is significant, in some
contexts (years ago, that one was a pain to track down), and in code,
e.g., after a backslash.  There's only one Makefile.in with a trailing
blank, and it's a  harmless one, so I can't point to a specific fault
here.  This is just preventive medicin.

Only about 1/3 of the affected lines (600+ lines in 217 files in LVM2)
are in code.  The majority are in man pages and on Copyright lines.

I'll even add a "make distcheck" rule that fails when a new one is
introduced.

Ok?


